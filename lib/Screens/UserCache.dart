// ============================================================
//  UserCache.dart
//  A simple cache layer using shared_preferences to store:
//    • User profile  : name, email, photoUrl
//    • Quiz stats    : total attempts, per-category attempts,
//                      best score per category
//
//  Usage:
//    await UserCache.saveProfile(name: "Alex", email: "alex@mail.com");
//    final profile = await UserCache.loadProfile();
//    await UserCache.recordAttempt(category: "Science", score: 8, total: 10);
//    final stats = await UserCache.loadStats();
//
//  Add to pubspec.yaml:
//    dependencies:
//      shared_preferences: ^2.2.3
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  Data Models
// ─────────────────────────────────────────────────────────────

class UserProfile {
  final String name;
  final String email;
  final String photoUrl; // network URL or empty string

  const UserProfile({
    required this.name,
    required this.email,
    this.photoUrl = '',
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    photoUrl: json['photoUrl'] ?? '',
  );

  UserProfile copyWith({String? name, String? email, String? photoUrl}) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
      );
}

class CategoryStat {
  final String category;
  final int attempts; // how many times attempted
  final int bestScore; // best raw score (correct answers)
  final int totalQ; // total questions in best attempt

  const CategoryStat({
    required this.category,
    required this.attempts,
    required this.bestScore,
    required this.totalQ,
  });

  double get bestPercent => totalQ == 0 ? 0 : (bestScore / totalQ) * 100;

  Map<String, dynamic> toJson() => {
    'category': category,
    'attempts': attempts,
    'bestScore': bestScore,
    'totalQ': totalQ,
  };

  factory CategoryStat.fromJson(Map<String, dynamic> json) => CategoryStat(
    category: json['category'] ?? '',
    attempts: json['attempts'] ?? 0,
    bestScore: json['bestScore'] ?? 0,
    totalQ: json['totalQ'] ?? 0,
  );
}

class UserStats {
  final int totalAttempts;
  final int totalScore;
  final Map<String, CategoryStat> categories; // key = category name

  const UserStats({
    required this.totalAttempts,
    required this.totalScore,
    required this.categories,
  });

  Map<String, dynamic> toJson() => {
    'totalAttempts': totalAttempts,
    'totalScore': totalScore,
    'categories': categories.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalAttempts: json['totalAttempts'] ?? 0,
    totalScore: json['totalScore'] ?? 0,
    categories: (json['categories'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, CategoryStat.fromJson(v as Map<String, dynamic>)),
    ),
  );

  factory UserStats.empty() =>
      const UserStats(totalAttempts: 0, totalScore: 0, categories: {});
}

class LocalAuthUser {
  final String name;
  final String email;
  final String password;

  const LocalAuthUser({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
  };

  factory LocalAuthUser.fromJson(Map<String, dynamic> json) => LocalAuthUser(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    password: json['password'] ?? '',
  );
}

class QuizRoom {
  final String id;
  final String code;
  final String title;
  final String category;
  final String difficulty;
  final bool isPublicRoom;
  final int timerSeconds;
  final List<Map<String, dynamic>> questions;
  final DateTime? expiresAt;
  final String status;
  final int participantCount;

  const QuizRoom({
    required this.id,
    required this.code,
    required this.title,
    required this.category,
    required this.difficulty,
    required this.isPublicRoom,
    required this.timerSeconds,
    required this.questions,
    this.expiresAt,
    this.status = 'active',
    this.participantCount = 0,
  });

  factory QuizRoom.fromJson(String id, Map<String, dynamic> json) => QuizRoom(
    id: id,
    code: json['code'] as String? ?? '',
    title: json['title'] as String? ?? '',
    category: json['category'] as String? ?? '',
    difficulty: json['difficulty'] as String? ?? '',
    isPublicRoom: json['isPublicRoom'] as bool? ?? true,
    timerSeconds: json['timerSeconds'] as int? ?? 20,
    questions: (json['questions'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList(),
    expiresAt: UserCache.parseRoomExpiry(json['expiresAt']),
    status: json['status'] as String? ?? 'active',
    participantCount: json['participantCount'] as int? ?? 0,
  );
}

// ─────────────────────────────────────────────────────────────
//  Cache Keys
// ─────────────────────────────────────────────────────────────

class _Keys {
  static const profile = 'user_profile';
  static const stats = 'user_stats';
  static const history = 'quiz_history';
  static const savedQuizzes = 'saved_quizzes';
  static const authUser = 'auth_user';
  static const isLoggedIn = 'is_logged_in';
  static const deviceGuestId = 'device_guest_id';
  static const seenCategoryQuestions = 'seen_category_questions';
}

// ─────────────────────────────────────────────────────────────
//  UserCache  –  static helper class
// ─────────────────────────────────────────────────────────────

class UserCache {
  UserCache._(); // prevent instantiation
  static const answersKey = 'user_answers';
  static const _quizRoomsCollection = 'quizRooms';
  static const Duration roomCodeLifetime = Duration(minutes: 10);

  static CollectionReference<Map<String, dynamic>> _quizRooms() =>
      FirebaseFirestore.instance.collection(_quizRoomsCollection);

  static Future<String> _activeScope() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser?.uid.isNotEmpty ?? false) {
      return firebaseUser!.uid;
    }

    final prefs = await SharedPreferences.getInstance();
    final rawAuthUser = prefs.getString(_Keys.authUser);
    if (rawAuthUser != null) {
      try {
        final authUser = LocalAuthUser.fromJson(
          jsonDecode(rawAuthUser) as Map<String, dynamic>,
        );
        if (authUser.email.trim().isNotEmpty) {
          return authUser.email.trim().toLowerCase();
        }
      } catch (_) {}
    }

    return 'guest';
  }

  static Future<String> _deviceGuestId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_Keys.deviceGuestId);
    if (existing != null && existing.isNotEmpty) return existing;

    final generated = DateTime.now().microsecondsSinceEpoch.toString();
    await prefs.setString(_Keys.deviceGuestId, generated);
    return generated;
  }

  static Future<Map<String, String>> _resolveRoomParticipant() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final cachedProfile = await loadCachedProfile();
    final authUser = await loadAuthUser();

    final participantId =
        (firebaseUser?.uid.isNotEmpty ?? false)
        ? firebaseUser!.uid
        : (authUser?.email.trim().isNotEmpty ?? false)
        ? authUser!.email.trim().toLowerCase()
        : 'guest_${await _deviceGuestId()}';

    final participantName =
        (firebaseUser?.displayName?.trim().isNotEmpty ?? false)
        ? firebaseUser!.displayName!.trim()
        : (cachedProfile?.name.trim().isNotEmpty ?? false)
        ? cachedProfile!.name.trim()
        : (authUser?.name.trim().isNotEmpty ?? false)
        ? authUser!.name.trim()
        : 'Guest Player';

    final participantEmail =
        (firebaseUser?.email?.trim().isNotEmpty ?? false)
        ? firebaseUser!.email!.trim()
        : (cachedProfile?.email.trim().isNotEmpty ?? false)
        ? cachedProfile!.email.trim()
        : (authUser?.email.trim().isNotEmpty ?? false)
        ? authUser!.email.trim()
        : '';

    return {
      'id': participantId,
      'name': participantName,
      'email': participantEmail,
    };
  }

  static Future<String> _scopedKey(String key) async {
    final scope = await _activeScope();
    return '$key::$scope';
  }

  static String? _currentUid() => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>>? _userDoc() {
    final uid = _currentUid();
    if (uid == null || uid.isEmpty) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  static Future<void> _syncProfileToCloud(UserProfile profile) async {
    final userDoc = _userDoc();
    if (userDoc == null) return;

    await userDoc.set({
      'profile': profile.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> _syncStatsToCloud(UserStats stats) async {
    final userDoc = _userDoc();
    if (userDoc == null) return;

    await userDoc.set({
      'stats': stats.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Future<void> initializeCurrentUserData({
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedProfileKey = await _scopedKey(_Keys.profile);
    final scopedStatsKey = await _scopedKey(_Keys.stats);
    final scopedHistoryKey = await _scopedKey(_Keys.history);
    final scopedSavedQuizzesKey = await _scopedKey(_Keys.savedQuizzes);
    final scopedAnswersKey = await _scopedKey(answersKey);

    final profile = UserProfile(name: name, email: email, photoUrl: photoUrl);
    final stats = UserStats.empty();

    await prefs.setString(scopedProfileKey, jsonEncode(profile.toJson()));
    await prefs.setString(scopedStatsKey, jsonEncode(stats.toJson()));
    await prefs.setString(scopedHistoryKey, jsonEncode([]));
    await prefs.setString(scopedSavedQuizzesKey, jsonEncode([]));
    await prefs.setString(scopedAnswersKey, jsonEncode({}));

    try {
      await _syncProfileToCloud(profile);
      await _syncStatsToCloud(stats);
    } catch (e) {
      debugPrint('[UserCache] Failed to initialize cloud user data: $e');
    }
  }

  static Future<void> saveQuizAttempt({
    required Map<String, dynamic> attempt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = await _scopedKey(_Keys.history);
    final raw = prefs.getString(historyKey);
    List data = [];

    if (raw != null) {
      data = jsonDecode(raw);
    }

    data.add(attempt);

    await prefs.setString(historyKey, jsonEncode(data));
  }

  // ── LOAD QUIZ HISTORY ─────────────────────────

  static Future<List<Map<String, dynamic>>> loadQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyKey = await _scopedKey(_Keys.history);
    final raw = prefs.getString(historyKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw);

      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error loading quiz history: $e');
      return [];
    }
  }

  static Future<void> clearQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _scopedKey(_Keys.history));
  }

  static Future<void> saveAnswers({
    required String category,
    required List<Map<String, dynamic>> answersList,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedAnswersKey = await _scopedKey(answersKey);
    final raw = prefs.getString(scopedAnswersKey);
    Map<String, dynamic> data = {};

    if (raw != null) {
      data = jsonDecode(raw);
    }

    data[category] = answersList;

    await prefs.setString(scopedAnswersKey, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>> loadAnswers(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedAnswersKey = await _scopedKey(answersKey);
    final raw = prefs.getString(scopedAnswersKey);
    if (raw == null) return [];

    final data = jsonDecode(raw) as Map<String, dynamic>;

    if (!data.containsKey(category)) return [];

    return List<Map<String, dynamic>>.from(data[category]);
  }

  static Future<void> saveAuthUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final authUser = LocalAuthUser(
      name: name,
      email: email.trim(),
      password: password,
    );
    await prefs.setString(_Keys.authUser, jsonEncode(authUser.toJson()));
  }

  static Future<LocalAuthUser?> loadAuthUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.authUser);
    if (raw == null) return null;

    try {
      return LocalAuthUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[UserCache] Failed to parse auth user: $e');
      return null;
    }
  }

  static Future<bool> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final existingUser = await loadAuthUser();
    final normalizedEmail = email.trim().toLowerCase();

    if (existingUser != null &&
        existingUser.email.trim().toLowerCase() == normalizedEmail) {
      return false;
    }

    await saveAuthUser(name: name, email: normalizedEmail, password: password);
    await saveProfile(name: name, email: normalizedEmail);
    await setLoggedIn(true);
    return true;
  }

  static Future<bool> loginUser({
    required String email,
    required String password,
  }) async {
    final savedUser = await loadAuthUser();
    if (savedUser == null) return false;

    final matches =
        savedUser.email.trim().toLowerCase() == email.trim().toLowerCase() &&
        savedUser.password == password;

    if (!matches) return false;

    await updateProfile(name: savedUser.name, email: savedUser.email);
    await setLoggedIn(true);
    return true;
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_Keys.isLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_Keys.isLoggedIn) ?? false;
  }

  static Future<void> logoutUser() async {
    await setLoggedIn(false);
  }

  static Future<void> saveQuiz({
    required String title,
    bool useRandomSelection = false,
    int randomQuestionCount = 10,
    List<Map<String, dynamic>>? customQuestions,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuizzesKey = await _scopedKey(_Keys.savedQuizzes);
    final raw = prefs.getString(savedQuizzesKey);
    final List<Map<String, dynamic>> saved = raw == null
        ? []
        : List<Map<String, dynamic>>.from(
            (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
          );

    saved.removeWhere(
      (item) =>
          item['title'] == title &&
          item['useRandomSelection'] == useRandomSelection &&
          item['randomQuestionCount'] == randomQuestionCount &&
          jsonEncode(item['customQuestions'] ?? []) ==
              jsonEncode(customQuestions ?? const []),
    );

    final savedId = customQuestions != null && customQuestions.isNotEmpty
        ? '${title}_${customQuestions.length}_${customQuestions.first['question'] ?? ''}'
        : '${title}_$useRandomSelection\_$randomQuestionCount';

    saved.add({
      'id': savedId,
      'title': title,
      'useRandomSelection': useRandomSelection,
      'randomQuestionCount': randomQuestionCount,
      'customQuestions': customQuestions ?? [],
      'savedAt': DateTime.now().toIso8601String(),
    });

    await prefs.setString(savedQuizzesKey, jsonEncode(saved));
  }

  static Future<Set<String>> loadSeenCategoryQuestionKeys(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedSeenKey = await _scopedKey(_Keys.seenCategoryQuestions);
    final raw = prefs.getString(scopedSeenKey);
    if (raw == null) return <String>{};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final categoryItems = decoded[category];
      if (categoryItems is! List) return <String>{};
      return categoryItems.map((item) => item.toString()).toSet();
    } catch (e) {
      debugPrint('[UserCache] Failed to parse seen category questions: $e');
      return <String>{};
    }
  }

  static Future<void> saveSeenCategoryQuestionKeys({
    required String category,
    required Set<String> questionKeys,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedSeenKey = await _scopedKey(_Keys.seenCategoryQuestions);
    Map<String, dynamic> data = {};
    final raw = prefs.getString(scopedSeenKey);

    if (raw != null) {
      try {
        data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      } catch (_) {}
    }

    data[category] = questionKeys.toList();
    await prefs.setString(scopedSeenKey, jsonEncode(data));
  }

  static Future<void> clearSeenCategoryQuestionKeys(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final scopedSeenKey = await _scopedKey(_Keys.seenCategoryQuestions);
    final raw = prefs.getString(scopedSeenKey);
    if (raw == null) return;

    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      data.remove(category);
      await prefs.setString(scopedSeenKey, jsonEncode(data));
    } catch (e) {
      debugPrint('[UserCache] Failed to clear seen category questions: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> loadSavedQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuizzesKey = await _scopedKey(_Keys.savedQuizzes);
    final raw = prefs.getString(savedQuizzesKey);
    if (raw == null) return [];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];

      return decoded
          .map((e) => Map<String, dynamic>.from(e))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      debugPrint('[UserCache] Failed to parse saved quizzes: $e');
      return [];
    }
  }

  static Future<void> removeSavedQuiz(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuizzesKey = await _scopedKey(_Keys.savedQuizzes);
    final saved = await loadSavedQuizzes();
    saved.removeWhere((item) => item['id'] == id);
    await prefs.setString(savedQuizzesKey, jsonEncode(saved.reversed.toList()));
  }

  static Future<String> createQuizRoom({
    required String title,
    required String category,
    required String difficulty,
    required bool isPublicRoom,
    required int timerSeconds,
    required List<Map<String, dynamic>> questions,
  }) async {
    final rooms = _quizRooms();
    final ownerId = _currentUid();
    final ownerEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final expiresAt = DateTime.now().add(roomCodeLifetime);

    for (int i = 0; i < 10; i++) {
      final code = _generateRoomCode();
      final existing = await rooms.where('code', isEqualTo: code).limit(1).get();
      if (existing.docs.isNotEmpty) continue;

      await rooms.add({
        'code': code,
        'title': title,
        'category': category,
        'difficulty': difficulty,
        'isPublicRoom': isPublicRoom,
        'timerSeconds': timerSeconds,
        'questions': questions,
        'createdBy': ownerId,
        'createdByEmail': ownerEmail,
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'status': 'active',
        'participantCount': 0,
      });

      return code;
    }

    throw Exception('Unable to generate room code. Please try again.');
  }

  static Future<QuizRoom> joinQuizRoom(String code) async {
    final normalizedCode = code.trim();
    if (normalizedCode.isEmpty) {
      throw Exception('Enter a room code first');
    }

    final snapshot = await _quizRooms()
        .where('code', isEqualTo: normalizedCode)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      throw Exception('Room code not found');
    }

    final doc = snapshot.docs.first;
    final room = QuizRoom.fromJson(doc.id, doc.data());

    if (room.expiresAt != null && DateTime.now().isAfter(room.expiresAt!)) {
      try {
        await doc.reference.set({'status': 'expired'}, SetOptions(merge: true));
      } catch (_) {}
      throw Exception('This room code has expired. Ask the host for a new code.');
    }

    if (room.status != 'active') {
      throw Exception('This room is no longer available to join.');
    }

    final participant = await _resolveRoomParticipant();
    final participantRef = doc.reference
        .collection('participants')
        .doc(participant['id']);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final roomSnapshot = await transaction.get(doc.reference);
      final participantSnapshot = await transaction.get(participantRef);
      final roomData = roomSnapshot.data();
      final refreshedExpiry = parseRoomExpiry(roomData?['expiresAt']);
      final refreshedStatus = roomData?['status'] as String? ?? 'active';

      if (refreshedStatus != 'active') {
        throw Exception('This room is no longer available to join.');
      }

      if (refreshedExpiry != null && DateTime.now().isAfter(refreshedExpiry)) {
        transaction.set(
          doc.reference,
          {'status': 'expired'},
          SetOptions(merge: true),
        );
        throw Exception(
          'This room code has expired. Ask the host for a new code.',
        );
      }

      transaction.set(participantRef, {
        'participantId': participant['id'],
        'name': participant['name'],
        'email': participant['email'],
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!participantSnapshot.exists) {
        final currentCount = roomData?['participantCount'] as int? ?? 0;
        transaction.set(
          doc.reference,
          {'participantCount': currentCount + 1},
          SetOptions(merge: true),
        );
      }
    });

    return room;
  }

  static Future<void> saveRoomParticipantAttempt({
    required String roomId,
    required int score,
    required int totalQuestions,
  }) async {
    if (roomId.trim().isEmpty) return;

    final participant = await _resolveRoomParticipant();
    final participantRef = _quizRooms()
        .doc(roomId)
        .collection('participants')
        .doc(participant['id']);

    final percent = totalQuestions == 0 ? 0.0 : (score / totalQuestions) * 100;

    await participantRef.set({
      'participantId': participant['id'],
      'name': participant['name'],
      'email': participant['email'],
      'completedAt': FieldValue.serverTimestamp(),
      'lastScore': score,
      'totalQuestions': totalQuestions,
      'percentage': percent,
    }, SetOptions(merge: true));
  }

  static String _generateRoomCode() {
    final now = DateTime.now().microsecondsSinceEpoch.toString();
    return now.substring(now.length - 6);
  }

  static DateTime? parseRoomExpiry(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  // ── Profile ──────────────────────────────────────────────

  /// Save / update the user profile in cache.
  static Future<void> saveProfile({
    required String name,
    required String email,
    String photoUrl = '',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final profile = UserProfile(name: name, email: email, photoUrl: photoUrl);
    await prefs.setString(
      await _scopedKey(_Keys.profile),
      jsonEncode(profile.toJson()),
    );
    try {
      await _syncProfileToCloud(profile);
      await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
      if (photoUrl.isNotEmpty) {
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(photoUrl);
      }
    } catch (e) {
      debugPrint('[UserCache] Failed to sync profile to cloud: $e');
    }
    debugPrint('[UserCache] Profile saved: $name');
  }

  /// Load the user profile from cache. Returns null if not found.
  static Future<UserProfile?> loadProfile() async {
    final cachedProfile = await loadCachedProfile();
    final userDoc = _userDoc();
    if (userDoc != null) {
      try {
        final snapshot = await userDoc.get();
        final cloudProfile = snapshot.data()?['profile'];
        if (cloudProfile is Map) {
          final profile = UserProfile.fromJson(
            Map<String, dynamic>.from(cloudProfile),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            await _scopedKey(_Keys.profile),
            jsonEncode(profile.toJson()),
          );
          return profile;
        }
      } catch (e) {
        debugPrint('[UserCache] Failed to load cloud profile: $e');
      }
    }

    return cachedProfile;
  }

  static Future<UserProfile?> loadCachedProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _scopedKey(_Keys.profile));
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[UserCache] Failed to parse profile: $e');
      return null;
    }
  }

  static Future<UserProfile?> refreshProfileFromCloud() async {
    final userDoc = _userDoc();
    if (userDoc == null) return null;

    try {
      final snapshot = await userDoc.get();
      final cloudProfile = snapshot.data()?['profile'];
      if (cloudProfile is Map) {
        final profile = UserProfile.fromJson(
          Map<String, dynamic>.from(cloudProfile),
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          await _scopedKey(_Keys.profile),
          jsonEncode(profile.toJson()),
        );
        return profile;
      }
    } catch (e) {
      debugPrint('[UserCache] Failed to refresh cloud profile: $e');
    }

    return null;
  }

  /// Update only specific profile fields while keeping the rest.
  static Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    final current =
        await loadProfile() ?? const UserProfile(name: '', email: '');
    final authUser = await loadAuthUser();

    final updatedName = name ?? current.name;
    final updatedEmail = email ?? current.email;
    final updatedPhotoUrl = photoUrl ?? current.photoUrl;

    await saveProfile(
      name: updatedName,
      email: updatedEmail,
      photoUrl: updatedPhotoUrl,
    );

    if (authUser != null) {
      await saveAuthUser(
        name: updatedName,
        email: updatedEmail,
        password: authUser.password,
      );
    }
  }

  static Future<String?> uploadProfilePhoto(String filePath) async {
    final uid = _currentUid();
    if (uid == null || uid.isEmpty) return null;

    try {
      final extension = path.extension(filePath).toLowerCase();
      final safeExtension = extension.isNotEmpty ? extension : '.jpg';
      final ref = FirebaseStorage.instance.ref().child(
        'profile_photos/$uid$safeExtension',
      );
      await ref.putFile(File(filePath));
      final downloadUrl = await ref.getDownloadURL();
      await updateProfile(photoUrl: downloadUrl);
      return downloadUrl;
    } catch (_) {}
    return null;
  }

  // ── Stats ─────────────────────────────────────────────────

  /// Record one quiz attempt. Call this when the user finishes a quiz.
  ///   [category]  = category name e.g. "Science"
  ///   [score]     = number of correct answers
  ///   [total]     = total number of questions
  static Future<void> recordAttempt({
    required String category,
    required int score,
    required int total,
  }) async {
    final stats = await loadStats();

    final existing = stats.categories[category];
    final newAttempts = (existing?.attempts ?? 0) + 1;
    final newBest = score > (existing?.bestScore ?? -1)
        ? score
        : (existing?.bestScore ?? 0);
    final newTotal = score > (existing?.bestScore ?? -1)
        ? total
        : (existing?.totalQ ?? total);

    final updatedCategories = Map<String, CategoryStat>.from(stats.categories);
    updatedCategories[category] = CategoryStat(
      category: category,
      attempts: newAttempts,
      bestScore: newBest,
      totalQ: newTotal,
    );

    final updated = UserStats(
      totalAttempts: stats.totalAttempts + 1,
      totalScore: stats.totalScore + score,
      categories: updatedCategories,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(await _scopedKey(_Keys.stats), jsonEncode(updated.toJson()));
    try {
      await _syncStatsToCloud(updated);
    } catch (e) {
      debugPrint('[UserCache] Failed to sync stats to cloud: $e');
    }
    debugPrint('[UserCache] Attempt recorded: $category  $score/$total');
  }

  /// Load all quiz stats from cache.
  static Future<UserStats> loadStats() async {
    final userDoc = _userDoc();
    if (userDoc != null) {
      try {
        final snapshot = await userDoc.get();
        final cloudStats = snapshot.data()?['stats'];
        if (cloudStats is Map) {
          final stats = UserStats.fromJson(
            Map<String, dynamic>.from(cloudStats),
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            await _scopedKey(_Keys.stats),
            jsonEncode(stats.toJson()),
          );
          return stats;
        }
      } catch (e) {
        debugPrint('[UserCache] Failed to load cloud stats: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(await _scopedKey(_Keys.stats));
    if (raw == null) return UserStats.empty();
    try {
      return UserStats.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[UserCache] Failed to parse stats: $e');
      return UserStats.empty();
    }
  }

  // ── Clear ─────────────────────────────────────────────────

  /// Remove only the profile from cache.
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _scopedKey(_Keys.profile));
  }

  /// Remove only the stats from cache.
  static Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(await _scopedKey(_Keys.stats));
  }

  /// Wipe everything (profile + stats).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_Keys.profile);
    await prefs.remove(_Keys.stats);
    await prefs.remove(_Keys.savedQuizzes);
    await prefs.remove(_Keys.authUser);
    await prefs.remove(_Keys.isLoggedIn);
    debugPrint('[UserCache] All data cleared.');
  }

  static Future<void> init() async {}
}
