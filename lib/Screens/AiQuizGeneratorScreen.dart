import 'package:flutter/material.dart';
import 'package:quiz/Screens/ProfileScreen.dart';
import 'package:quiz/Screens/QuizScreen.dart';
import 'package:quiz/Services/groq_quiz_service.dart';

class AiQuizGeneratorScreen extends StatefulWidget {
  const AiQuizGeneratorScreen({super.key});

  @override
  State<AiQuizGeneratorScreen> createState() => _AiQuizGeneratorScreenState();
}

class _AiQuizGeneratorScreenState extends State<AiQuizGeneratorScreen> {
  final TextEditingController _topicController = TextEditingController();
  bool _isGenerating = false;
  String _languageStyle = 'simple';

  final List<String> _quickTopics = const [
    'Physics',
    'Biology',
    'History',
    'Geography',
    'Programming',
    'Chemistry',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.text)),
        backgroundColor: AppColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }

  Future<void> _generateQuiz() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      _toast('Enter a subject or topic first');
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final questions = await GroqQuizService.generateQuiz(
        topic: topic,
        languageStyle: _languageStyle,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            topic,
            customQuestions: questions,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1322),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B1322),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'AI Quiz Generator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF223E9A), Color(0xFF18274A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create a topic quiz with Groq AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Enter any subject and the backend will generate 10 related MCQ questions in easy to medium level.',
                      style: TextStyle(
                        color: Color(0xFFB8C6EA),
                        fontSize: 15,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Topic Name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF141D2E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF263249)),
                ),
                child: TextField(
                  controller: _topicController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Example: Biology, Java, World History',
                    hintStyle: TextStyle(color: Color(0xFF71819A)),
                    prefixIcon: Icon(
                      Icons.auto_awesome_outlined,
                      color: Color(0xFF67AEFF),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Ideas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _quickTopics.map((topic) {
                  return ActionChip(
                    onPressed: () {
                      setState(() {
                        _topicController.text = topic;
                      });
                    },
                    backgroundColor: const Color(0xFF1A2436),
                    side: const BorderSide(color: Color(0xFF263249)),
                    label: Text(
                      topic,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 26),
              const Text(
                'Language Style',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF141D2E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF263249)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _styleButton(
                        label: 'Simple',
                        value: 'simple',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _styleButton(
                        label: 'Advanced',
                        value: 'advanced',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF121A28),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF243249)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generated format',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Difficulty: Easy to Medium\nQuestion Type: MCQs\nTotal Questions: 10',
                      style: TextStyle(
                        color: Color(0xFF9FB0C9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _generateQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2C8FFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isGenerating
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.3,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Generate 10 Questions',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _styleButton({
    required String label,
    required String value,
  }) {
    final selected = _languageStyle == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _languageStyle = value;
        });
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6C63FF) : const Color(0xFF1A2436),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
