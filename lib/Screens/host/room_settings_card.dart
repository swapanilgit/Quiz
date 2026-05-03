import 'package:flutter/material.dart';

class RoomSettingsCard extends StatelessWidget {
  final bool isPublicRoom;
  final ValueChanged<bool> onPublicRoomChanged;
  final double timerSeconds;
  final ValueChanged<double> onTimerChanged;

  const RoomSettingsCard({
    super.key,
    required this.isPublicRoom,
    required this.onPublicRoomChanged,
    required this.timerSeconds,
    required this.onTimerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF182435),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF223247)),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Public Room',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Make quiz visible to everyone',
                      style: TextStyle(
                        color: Color(0xFF8DA0B8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isPublicRoom,
                onChanged: onPublicRoomChanged,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF2D8CFF),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF32445A),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
              Row(
                children: [
                  const Text(
                    'Timer per Question',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${timerSeconds.round()}s',
                    style: const TextStyle(
                      color: Color(0xFF2D8CFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF2D8CFF),
                  inactiveTrackColor: const Color(0xFF2A3A4D),
                  thumbColor: const Color(0xFF2D8CFF),
                  overlayColor: const Color(0x332D8CFF),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: timerSeconds,
                  min: 5,
                  max: 120,
                  divisions: 23,
                  onChanged: onTimerChanged,
                ),
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text(
                    '5s',
                    style: TextStyle(color: Color(0xFF8DA0B8)),
                  ),
                  Spacer(),
                  Text(
                    '60s',
                    style: TextStyle(color: Color(0xFF8DA0B8)),
                  ),
                  Spacer(),
                  Text(
                    '120s',
                    style: TextStyle(color: Color(0xFF8DA0B8)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
