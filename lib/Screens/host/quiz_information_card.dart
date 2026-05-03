import 'package:flutter/material.dart';
import 'package:quiz/Screens/host/host_models.dart';

class QuizInformationCard extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController subjectController;
  final HostDifficulty difficulty;
  final ValueChanged<HostDifficulty> onDifficultyChanged;

  const QuizInformationCard({
    super.key,
    required this.titleController,
    required this.subjectController,
    required this.difficulty,
    required this.onDifficultyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF182435),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF223247)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('QUIZ TITLE'),
          const SizedBox(height: 12),
          _darkField(
            child: TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter an engaging title...',
                hintStyle: TextStyle(color: Color(0xFF62738D)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _label('SUBJECT'),
          const SizedBox(height: 12),
          _darkField(
            child: TextField(
              controller: subjectController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter subject name...',
                hintStyle: TextStyle(color: Color(0xFF62738D)),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _label('DIFFICULTY'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF111B28),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF24354A)),
            ),
            child: Row(
              children: HostDifficulty.values
                  .map(
                    (level) => Expanded(
                      child: GestureDetector(
                        onTap: () => onDifficultyChanged(level),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: difficulty == level
                                ? const Color(0xFF2D8CFF)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _difficultyLabel(level),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: difficulty == level
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF9DB0C7),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _darkField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF111B28),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF24354A)),
      ),
      child: child,
    );
  }

  String _difficultyLabel(HostDifficulty difficulty) {
    switch (difficulty) {
      case HostDifficulty.easy:
        return 'Easy';
      case HostDifficulty.medium:
        return 'Medium';
      case HostDifficulty.hard:
        return 'Hard';
    }
  }
}
