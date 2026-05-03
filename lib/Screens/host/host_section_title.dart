import 'package:flutter/material.dart';

class HostSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;

  const HostSectionTitle({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2D8CFF), size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (trailingText != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF21324B),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailingText!,
              style: const TextStyle(
                color: Color(0xFF2D8CFF),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}
