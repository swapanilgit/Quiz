import 'package:flutter/material.dart';
import 'package:quiz/Screens/ProfileScreen.dart';
import 'package:quiz/Screens/UserCache.dart';

// ─────────────────────────────────────────────
// MODELS (same as before)
// ─────────────────────────────────────────────

class QuizAttempt {
  final String id;
  final String subject;
  final DateTime date;
  final int totalQuestions;
  final int correctAnswers;
  final List<QuestionResult> questions;

  QuizAttempt({
    required this.id,
    required this.subject,
    required this.date,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.questions,
  });

  int get wrongAnswers => totalQuestions - correctAnswers;
  double get percentage => (correctAnswers / totalQuestions) * 100;
}

class QuestionResult {
  final int questionNo;
  final String question;
  final String correctAnswer;
  final String selectedAnswer;
  final bool isCorrect;

  QuestionResult({
    required this.questionNo,
    required this.question,
    required this.correctAnswer,
    required this.selectedAnswer,
    required this.isCorrect,
  });
}

// ─────────────────────────────────────────────
// MAIN PAGE
// ─────────────────────────────────────────────

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage> {
  late Future<List<QuizAttempt>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadAttempts();
  }

  Future<List<QuizAttempt>> _loadAttempts() async {
    final data = await UserCache.loadQuizHistory();

    return data
        .map((item) {
          return QuizAttempt(
            id: item['id'],
            subject: item['subject'],
            date: DateTime.parse(item['date']),
            totalQuestions: item['totalQuestions'],
            correctAnswers: item['correctAnswers'],
            questions: (item['questions'] as List)
                .map(
                  (q) => QuestionResult(
                    questionNo: q['questionNo'],
                    question: q['question'],
                    correctAnswer: q['correctAnswer'],
                    selectedAnswer: q['selectedAnswer'],
                    isCorrect: q['isCorrect'],
                  ),
                )
                .toList(),
          );
        })
        .toList()
        .reversed
        .toList(); // latest first
  }

  void _refresh() {
    setState(() {
      _future = _loadAttempts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text('Quiz History'),
      ),
      body: FutureBuilder<List<QuizAttempt>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final attempts = snapshot.data ?? [];

          if (attempts.isEmpty) {
            return const Center(
              child: Text(
                'No quiz attempts yet',
                style: TextStyle(color: AppColors.subtext),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: attempts.length,
              itemBuilder: (_, i) {
                final a = attempts[i];
                return _buildCard(a);
              },
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  // CARD
  // ─────────────────────────────────────────────

  Widget _buildCard(QuizAttempt a) {
    final percent = a.percentage;

    Color color;
    if (percent >= 70) {
      color = AppColors.indigo;
    } else if (percent >= 40) {
      color = Colors.orange;
    } else {
      color = AppColors.red;
    }

    return GestureDetector(
      onTap: () => _showDetails(a),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.15),
              child: Text(
                '${percent.toStringAsFixed(0)}%',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    _formatDate(a.date),
                    style: const TextStyle(
                      color: AppColors.subtext,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score: ${a.correctAnswers}/${a.totalQuestions}  (❌ ${a.wrongAnswers})',
                    style: const TextStyle(color: AppColors.subtext),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.subtext,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // DETAIL VIEW
  // ─────────────────────────────────────────────

  void _showDetails(QuizAttempt attempt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: attempt.questions.length,
          itemBuilder: (_, i) {
            final q = attempt.questions[i];

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: q.isCorrect ? AppColors.card : AppColors.redBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  q.question,
                  style: const TextStyle(color: AppColors.text),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your: ${q.selectedAnswer}',
                      style: const TextStyle(color: AppColors.subtext),
                    ),
                    if (!q.isCorrect)
                      Text(
                        'Correct: ${q.correctAnswer}',
                        style: const TextStyle(color: AppColors.indigoLight),
                      ),
                  ],
                ),
                trailing: Icon(
                  q.isCorrect ? Icons.check : Icons.close,
                  color: q.isCorrect ? AppColors.indigo : AppColors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  String _formatDate(DateTime d) {
    return '${d.day}/${d.month}/${d.year}';
  }
}
