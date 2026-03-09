import 'dart:async';

import "package:flutter/material.dart";

class Question {
  final String question;
  final List<String> options;
  final int correctIndex;

  final String title;

  Question({
    required this.title,
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class QuizScreen extends StatefulWidget {
  final title;

  const QuizScreen(this.title, {super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentIndex = 0;
  int selectedIndex = -1;
  int score = 0;
  int seconds = 15;
  Timer? timer;
  late List<Question> questions;
  bool isTimeUp = false;

  final Map<String, List<Question>> allQuestions = {
    "Science": [
      Question(
        title: "Science",
        question: "Which planet is known as the Red Planet?",
        options: ["Mars", "Venus", "Jupiter", "Saturn"],
        correctIndex: 0,
      ),
      Question(
        title: "Science",
        question: "Which planet is the biggest in our solar system?",
        options: ["Earth", "Mars", "Jupiter", "Saturn"],
        correctIndex: 2,
      ),
    ],

    "History": [
      Question(
        title: "History",
        question: "Who was the first President of India?",
        options: [
          "Dr. Rajendra Prasad",
          "Jawaharlal Nehru",
          "Mahatma Gandhi",
          "Sardar Patel",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "History",
        question: "In which year did India get Independence?",
        options: ["1945", "1946", "1947", "1950"],
        correctIndex: 2,
      ),
    ],

    "Computer": [
      Question(
        title: "Computer",
        question: "What does CPU stand for?",
        options: [
          "Central Processing Unit",
          "Computer Personal Unit",
          "Central Program Unit",
          "Control Processing Unit",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "Computer",
        question: "Which language is used to build Flutter apps?",
        options: ["Java", "Dart", "Python", "C++"],
        correctIndex: 1,
      ),
    ],

    "Art & Design": [
      Question(
        title: "Art & Design",
        question: "Who painted the Mona Lisa?",
        options: [
          "Vincent Van Gogh",
          "Leonardo da Vinci",
          "Pablo Picasso",
          "Michelangelo",
        ],
        correctIndex: 1,
      ),
      Question(
        title: "Art & Design",
        question: "Which color is created by mixing red and blue?",
        options: ["Green", "Purple", "Orange", "Brown"],
        correctIndex: 1,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();

    // Load questions based on selected category
    questions = allQuestions[widget.title] ?? [];

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void autoNextQuestion() {
    // DO NOT increase score if nothing selected
    if (selectedIndex == questions[currentIndex].correctIndex) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = -1;
      });
      restartTimer();
    } else {
      timer?.cancel();
      showResult();
    }
  }

  void restartTimer() {
    timer?.cancel();
    isTimeUp = false;
    seconds = 15;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
        setState(() {
          isTimeUp = true;
        });

        Future.delayed(const Duration(milliseconds: 400), () {
          autoNextQuestion();
        });
      } else {
        setState(() {
          seconds--;
        });
      }
    });
  }

  void showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          "Quiz Completed 🎉",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "Your Score: $score / ${questions.length}",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentIndex = 0;
                score = 0;
                selectedIndex = -1;
                seconds = 15;
              });
              restartTimer();
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  void submitAnswer() {
    if (isTimeUp) return; // Prevent submit after time up

    if (selectedIndex == -1) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select an answer")));
      return;
    }

    timer?.cancel();

    if (selectedIndex == questions[currentIndex].correctIndex) {
      score++;
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedIndex = -1;
      });
      restartTimer();
    } else {
      showResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    double progressValue = (currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              /// Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  Text(
                    "${widget.title} Quiz",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.help_outline, color: Colors.white),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "QUESTION PROGRESS",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${currentIndex + 1}/${questions.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  /// Timer Circle
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 70,
                        width: 70,
                        child: CircularProgressIndicator(
                          value: seconds / 15,
                          strokeWidth: 6,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(Colors.blue),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$seconds",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "SEC",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// Linear Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 8,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),

              const SizedBox(height: 40),

              /// Question
              Text(
                questions[currentIndex].question,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              /// Options
              Expanded(
                child: ListView.builder(
                  itemCount: questions[currentIndex].options.length,
                  itemBuilder: (context, index) {
                    return buildOption(index);
                  },
                ),
              ),

              /// Submit Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: submitAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Submit Answer",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildOption(int index) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: isTimeUp
          ? null
          : () {
              setState(() {
                selectedIndex = index;
              });
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.2)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white12,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? Colors.blue : Colors.white12,
              child: Text(
                String.fromCharCode(65 + index),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              questions[currentIndex].options[index],
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
