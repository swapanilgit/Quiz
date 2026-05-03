import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:quiz/Screens/QuizScreen.dart';

class GroqQuizService {
  GroqQuizService._();

  // Replace this with your backend URL.
  // Android emulator example: http://10.0.2.2:3000/api/ai-quiz
  // Local device example: http://192.168.1.5:3000/api/ai-quiz
  static const String backendUrl = 'http://10.0.2.2:3000/api/ai-quiz';

  static Future<List<Question>> generateQuiz({
    required String topic,
    String difficulty = 'easy_to_medium',
    String languageStyle = 'simple',
    int questionCount = 10,
    String questionType = 'mcq',
  }) async {
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'topic': topic.trim(),
        'difficulty': difficulty,
        'languageStyle': languageStyle,
        'questionCount': questionCount,
        'questionType': questionType,
      }),
    );

    if (response.statusCode != 200) {
      final fallbackMessage = 'Unable to generate quiz right now.';
      try {
        final errorJson = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(errorJson['message'] as String? ?? fallbackMessage);
      } catch (_) {
        throw Exception(fallbackMessage);
      }
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final rawQuestions = json['questions'] as List<dynamic>? ?? const [];

    if (rawQuestions.isEmpty) {
      throw Exception('No questions were generated for this topic.');
    }

    return rawQuestions
        .map((item) => Question.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
