import 'package:flutter/material.dart';
import 'package:quiz/Screens/HostScreen.dart';
import 'package:quiz/Screens/ProfileScreen.dart';
import 'package:quiz/Screens/QuizScreen.dart';
import 'package:quiz/Screens/UserCache.dart';

class OnlineQuizMakerScreen extends StatefulWidget {
  const OnlineQuizMakerScreen({super.key});

  @override
  State<OnlineQuizMakerScreen> createState() => _OnlineQuizMakerScreenState();
}

class _OnlineQuizMakerScreenState extends State<OnlineQuizMakerScreen> {
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isJoining = false;

  @override
  void dispose() {
    _roomCodeController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
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

  Future<void> _joinRoom() async {
    final code = _roomCodeController.text.trim();
    if (code.isEmpty) {
      _showToast('Enter a room code first');
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final room = await UserCache.joinQuizRoom(code);
      final questions = room.questions
          .map((item) => Question.fromJson(item))
          .toList();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizScreen(
            room.title,
            customQuestions: questions,
            questionDurationSeconds: room.timerSeconds,
            roomId: room.id,
            roomCode: room.code,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showToast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (!mounted) return;
      setState(() {
        _isJoining = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1524),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1120), Color(0xFF10202A), Color(0xFF0E1A25)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Center(
                  child: Column(
                    children: [
                      Text(
                        'GATEWAY ACCESS',
                        style: TextStyle(
                          color: Color(0xFF2C8FFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.2,
                        ),
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Choose Your Role',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Experience the precision of high-stakes competitive learning. Will you lead the room or dominate the board?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF97A6BC),
                          fontSize: 16,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 34),
                _roleCard(
                  accent: const Color(0xFF2C8FFF),
                  icon: Icons.add,
                  title: 'Create a Room',
                  description:
                      'Host your own quiz and challenge others. As a Creator, you control the pace, questions, and environment for your audience.',
                  bulletOne: 'Custom question banks',
                  bulletTwo: 'Real-time analytics',
                  action: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HostScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2C84E6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Host Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _roleCard(
                  accent: const Color(0xFF19B38A),
                  icon: Icons.meeting_room_outlined,
                  title: 'Join a Room',
                  description:
                      'Enter a room code and prove your knowledge. Compete against live participants and climb the room leaderboard.',
                  bulletOne: 'Fast room access',
                  bulletTwo: 'Secure code-based entry',
                  action: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2536),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF253247)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _roomCodeController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter 6-digit code',
                              hintStyle: TextStyle(
                                color: Color(0xFF71819A),
                                letterSpacing: 1.2,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isJoining ? null : _joinRoom,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF19B38A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                            ),
                            child: _isJoining
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Join',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 26),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF243142), width: 1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Echoes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1,248 active rooms globally across 14 categories.',
                        style: TextStyle(
                          color: Color(0xFF91A2BA),
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _avatarBubble(
                            background: const Color(0xFF244E6A),
                            text: 'A',
                          ),
                          Transform.translate(
                            offset: const Offset(-10, 0),
                            child: _avatarBubble(
                              background: const Color(0xFF1A866E),
                              text: 'B',
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(-20, 0),
                            child: _avatarBubble(
                              background: const Color(0xFF2588DB),
                              text: 'C',
                            ),
                          ),
                          Transform.translate(
                            offset: const Offset(-30, 0),
                            child: Container(
                              width: 42,
                              height: 42,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0xFF14335C),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF0E1A25),
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                '+1k',
                                style: TextStyle(
                                  color: Color(0xFF67AEFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard({
    required Color accent,
    required IconData icon,
    required String title,
    required String description,
    required String bulletOne,
    required String bulletTwo,
    required Widget action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF172334),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF243142)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accent.withOpacity(0.28)),
            ),
            child: Icon(icon, color: accent, size: 34),
          ),
          const SizedBox(height: 26),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF9EB0C6),
              fontSize: 16,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 22),
          _featureRow(bulletOne),
          const SizedBox(height: 10),
          _featureRow(bulletTwo),
          const SizedBox(height: 24),
          action,
        ],
      ),
    );
  }

  Widget _featureRow(String text) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle,
          size: 18,
          color: Color(0xFF8C9BB1),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFFA9B7CC),
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _avatarBubble({
    required Color background,
    required String text,
  }) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0E1A25), width: 2),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
