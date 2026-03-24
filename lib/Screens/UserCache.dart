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
  final Map<String, CategoryStat> categories; // key = category name

  const UserStats({required this.totalAttempts, required this.categories});

  Map<String, dynamic> toJson() => {
    'totalAttempts': totalAttempts,
    'categories': categories.map((k, v) => MapEntry(k, v.toJson())),
  };

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
    totalAttempts: json['totalAttempts'] ?? 0,
    categories: (json['categories'] as Map<String, dynamic>? ?? {}).map(
      (k, v) => MapEntry(k, CategoryStat.fromJson(v as Map<String, dynamic>)),
    ),
  );

  factory UserStats.empty() =>
      const UserStats(totalAttempts: 0, categories: {});
}

// ─────────────────────────────────────────────────────────────
//  Cache Keys
// ─────────────────────────────────────────────────────────────

class _Keys {
  static const profile = 'user_profile';
  static const stats = 'user_stats';
  static const history = 'quiz_history';
  static const savedQuizzes = 'saved_quizzes';
}

// ─────────────────────────────────────────────────────────────
//  UserCache  –  static helper class
// ─────────────────────────────────────────────────────────────

class UserCache {
  UserCache._(); // prevent instantiation
  static const answersKey = 'user_answers';
  static Future<void> saveQuizAttempt({
    required Map<String, dynamic> attempt,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_Keys.history);
    List data = [];

    if (raw != null) {
      data = jsonDecode(raw);
    }

    data.add(attempt);

    await prefs.setString(_Keys.history, jsonEncode(data));
  }

  // ── LOAD QUIZ HISTORY ─────────────────────────

  static Future<List<Map<String, dynamic>>> loadQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_Keys.history);
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

  static Future<void> saveAnswers({
    required String category,
    required List<Map<String, dynamic>> answersList,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(answersKey);
    Map<String, dynamic> data = {};

    if (raw != null) {
      data = jsonDecode(raw);
    }

    data[category] = answersList;

    await prefs.setString(answersKey, jsonEncode(data));
  }

  static Future<List<Map<String, dynamic>>> loadAnswers(String category) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(answersKey);
    if (raw == null) return [];

    final data = jsonDecode(raw) as Map<String, dynamic>;

    if (!data.containsKey(category)) return [];

    return List<Map<String, dynamic>>.from(data[category]);
  }

  static Future<void> saveQuiz({
    required String title,
    bool useRandomSelection = false,
    int randomQuestionCount = 10,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.savedQuizzes);
    final List<Map<String, dynamic>> saved = raw == null
        ? []
        : List<Map<String, dynamic>>.from(
            (jsonDecode(raw) as List).map((e) => Map<String, dynamic>.from(e)),
          );

    saved.removeWhere(
      (item) =>
          item['title'] == title &&
          item['useRandomSelection'] == useRandomSelection &&
          item['randomQuestionCount'] == randomQuestionCount,
    );

    saved.add({
      'id': '${title}_$useRandomSelection\_$randomQuestionCount',
      'title': title,
      'useRandomSelection': useRandomSelection,
      'randomQuestionCount': randomQuestionCount,
      'savedAt': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_Keys.savedQuizzes, jsonEncode(saved));
  }

  static Future<List<Map<String, dynamic>>> loadSavedQuizzes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.savedQuizzes);
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
    final saved = await loadSavedQuizzes();
    saved.removeWhere((item) => item['id'] == id);
    await prefs.setString(_Keys.savedQuizzes, jsonEncode(saved.reversed.toList()));
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
    await prefs.setString(_Keys.profile, jsonEncode(profile.toJson()));
    debugPrint('[UserCache] Profile saved: $name');
  }

  /// Load the user profile from cache. Returns null if not found.
  static Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.profile);
    if (raw == null) return null;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[UserCache] Failed to parse profile: $e');
      return null;
    }
  }

  /// Update only specific profile fields while keeping the rest.
  static Future<void> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    final current =
        await loadProfile() ?? const UserProfile(name: '', email: '');
    await saveProfile(
      name: name ?? current.name,
      email: email ?? current.email,
      photoUrl: photoUrl ?? current.photoUrl,
    );
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
      categories: updatedCategories,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Keys.stats, jsonEncode(updated.toJson()));
    debugPrint('[UserCache] Attempt recorded: $category  $score/$total');
  }

  /// Load all quiz stats from cache.
  static Future<UserStats> loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_Keys.stats);
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
    await prefs.remove(_Keys.profile);
  }

  /// Remove only the stats from cache.
  static Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_Keys.stats);
  }

  /// Wipe everything (profile + stats).
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_Keys.profile);
    await prefs.remove(_Keys.stats);
    await prefs.remove(_Keys.savedQuizzes);
    debugPrint('[UserCache] All data cleared.');
  }

  static Future<void> init() async {}
}
