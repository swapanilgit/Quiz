import 'package:flutter/material.dart';
import 'package:quiz/Screens/host/host_models.dart';

class QuestionBuilderCard extends StatelessWidget {
  final int index;
  final HostQuestionDraft question;
  final ValueChanged<String> onQuestionChanged;
  final void Function(int optionIndex, String value) onOptionChanged;
  final ValueChanged<int> onCorrectOptionChanged;
  final VoidCallback onDelete;
  final bool canDelete;

  const QuestionBuilderCard({
    super.key,
    required this.index,
    required this.question,
    required this.onQuestionChanged,
    required this.onOptionChanged,
    required this.onCorrectOptionChanged,
    required this.onDelete,
    required this.canDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2C3D),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2D8CFF), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Question ${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (canDelete)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete,
                    color: Color(0xFFFF4F73),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF162231),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextFormField(
              initialValue: question.question,
              onChanged: onQuestionChanged,
              minLines: 4,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Type your question here...',
                hintStyle: TextStyle(color: Color(0xFF667995)),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(4, (optionIndex) {
            return Padding(
              padding: EdgeInsets.only(bottom: optionIndex == 3 ? 0 : 12),
              child: _OptionTile(
                label: String.fromCharCode(65 + optionIndex),
                value: question.options[optionIndex],
                isSelected: question.correctIndex == optionIndex,
                onChanged: (value) => onOptionChanged(optionIndex, value),
                onTap: () => onCorrectOptionChanged(optionIndex),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final ValueChanged<String> onChanged;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF101A27),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2D8CFF)
                : const Color(0xFF223246),
          ),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2D8CFF)
                        : const Color(0xFF394D68),
                    width: 1.6,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Color(0xFF2D8CFF),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextFormField(
                initialValue: value,
                onChanged: onChanged,
                style: const TextStyle(color: Colors.white, fontSize: 17),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Option $label',
                  hintStyle: const TextStyle(color: Color(0xFF667995)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
