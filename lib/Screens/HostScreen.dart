import 'package:flutter/material.dart';
import 'package:quiz/Screens/OnlineQuizMakerScreen.dart';
import 'package:quiz/Screens/host/host_models.dart';
import 'package:quiz/Screens/host/host_section_title.dart';
import 'package:quiz/Screens/host/question_builder_card.dart';
import 'package:quiz/Screens/host/quiz_information_card.dart';
import 'package:quiz/Screens/host/room_settings_card.dart';
import 'package:quiz/Screens/UserCache.dart';

class HostScreen extends StatefulWidget {
  const HostScreen({super.key});

  @override
  State<HostScreen> createState() => _HostScreenState();
}

class _HostScreenState extends State<HostScreen> {
  final TextEditingController _quizTitleController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  HostDifficulty _difficulty = HostDifficulty.easy;
  final List<HostQuestionDraft> _questions = [HostQuestionDraft()];
  bool _isPublicRoom = true;
  double _timerSeconds = 15;
  bool _isPublishing = false;

  @override
  void dispose() {
    _quizTitleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _publishRoom() async {
    final title = _quizTitleController.text.trim();
    final subject = _subjectController.text.trim();
    if (title.isEmpty) {
      _showToast('Enter a quiz title first');
      return;
    }
    if (subject.isEmpty) {
      _showToast('Enter a subject name first');
      return;
    }

    for (final item in _questions) {
      if (item.question.trim().isEmpty) {
        _showToast('Every question needs text');
        return;
      }
      if (item.options.any((option) => option.trim().isEmpty)) {
        _showToast('Fill all four options for every question');
        return;
      }
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final questions = _questions
          .map(
            (item) => {
              'title': subject,
              'question': item.question.trim(),
              'options': item.options.map((option) => option.trim()).toList(),
              'correctIndex': item.correctIndex,
            },
          )
          .toList();

      final code = await UserCache.createQuizRoom(
        title: title,
        category: subject,
        difficulty: _difficulty.name,
        isPublicRoom: _isPublicRoom,
        timerSeconds: _timerSeconds.round(),
        questions: questions,
      );

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF182435),
          title: const Text(
            'Room Published',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Share this room code with players:',
                style: TextStyle(color: Color(0xFF9EB0C6)),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF111B28),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  code,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF2D8CFF),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This code will expire automatically after 10 minutes.',
                style: TextStyle(
                  color: Color(0xFF7F93AD),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showToast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() {
        _isPublishing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101A24),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101A24),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Quiz Creator',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _publishRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D8CFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
              child: _isPublishing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Publish',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HostSectionTitle(
                icon: Icons.info,
                title: 'Quiz Information',
              ),
              const SizedBox(height: 18),
              QuizInformationCard(
                titleController: _quizTitleController,
                subjectController: _subjectController,
                difficulty: _difficulty,
                onDifficultyChanged: (difficulty) {
                  setState(() {
                    _difficulty = difficulty;
                  });
                },
              ),
              const SizedBox(height: 34),
              HostSectionTitle(
                icon: Icons.library_add_check_outlined,
                title: 'Question Builder',
                trailingText: '${_questions.length} QUESTION',
              ),
              const SizedBox(height: 18),
              ...List.generate(_questions.length, (index) {
                final item = _questions[index];
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == _questions.length - 1 ? 0 : 18,
                  ),
                  child: QuestionBuilderCard(
                    index: index,
                    question: item,
                    onQuestionChanged: (value) {
                      item.question = value;
                    },
                    onOptionChanged: (optionIndex, value) {
                      item.options[optionIndex] = value;
                    },
                    onCorrectOptionChanged: (optionIndex) {
                      setState(() {
                        item.correctIndex = optionIndex;
                      });
                    },
                    onDelete: () {
                      setState(() {
                        _questions.removeAt(index);
                      });
                    },
                    canDelete: _questions.length > 1,
                  ),
                );
              }),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _questions.add(HostQuestionDraft());
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF24354A),
                    width: 1.2,
                  ),
                  minimumSize: const Size(double.infinity, 66),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.add_circle, color: Color(0xFFB8C5D8)),
                label: const Text(
                  'Add Another Question',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD4DEEB),
                  ),
                ),
              ),
              const SizedBox(height: 34),
              const HostSectionTitle(
                icon: Icons.settings,
                title: 'Room Settings',
              ),
              const SizedBox(height: 18),
              RoomSettingsCard(
                isPublicRoom: _isPublicRoom,
                onPublicRoomChanged: (value) {
                  setState(() {
                    _isPublicRoom = value;
                  });
                },
                timerSeconds: _timerSeconds,
                onTimerChanged: (value) {
                  setState(() {
                    _timerSeconds = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
