import 'dart:async';
import 'dart:math';

import "package:flutter/material.dart";
import 'package:quiz/Screens/AnsweredQuestion.dart';
import 'package:quiz/Screens/ProfileScreen.dart';
import 'package:quiz/Screens/UserCache.dart';

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
  final String title;
  final bool useRandomSelection;
  final int randomQuestionCount;

  const QuizScreen(
    this.title, {
    super.key,
    this.useRandomSelection = false,
    this.randomQuestionCount = 10,
  });

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
  bool _isSaved = false;
  bool _isShowingResult = false;
  bool _isQuizSaved = false;

  List<AnsweredQuestion> answered = [];

  void recordAnswer() {
    answered.add(
      AnsweredQuestion(
        question: questions[currentIndex].question,
        correctAnswer: questions[currentIndex]
            .options[questions[currentIndex].correctIndex],
        userAnswer: selectedIndex == -1
            ? "Not Answered"
            : questions[currentIndex].options[selectedIndex],
      ),
    );
  }

  final Map<String, List<Question>> allQuestions = {
    "Science": [
      Question(
        title: "Science",
        question: "Which planet is known as the Red Planet?",
        options: ["Earth", "Mars", "Jupiter", "Venus"],
        correctIndex: 1,
      ),
      Question(
        title: "Science",
        question: "What gas do humans need to breathe to survive?",
        options: ["Carbon Dioxide", "Oxygen", "Nitrogen", "Hydrogen"],
        correctIndex: 1,
      ),
      Question(
        title: "Science",
        question: "Which part of the plant makes food?",
        options: ["Root", "Stem", "Leaf", "Flower"],
        correctIndex: 2,
      ),
      Question(
        title: "Science",
        question: "What is the center of our solar system?",
        options: ["Earth", "Moon", "Sun", "Mars"],
        correctIndex: 2,
      ),
      Question(
        title: "Science",
        question: "Which organ pumps blood in the human body?",
        options: ["Brain", "Heart", "Lungs", "Kidney"],
        correctIndex: 1,
      ),
      Question(
        title: "Science",
        question: "What force pulls objects toward the Earth?",
        options: ["Magnetism", "Gravity", "Friction", "Energy"],
        correctIndex: 1,
      ),
      Question(
        title: "Science",
        question: "What is the boiling point of water?",
        options: ["50°C", "75°C", "100°C", "150°C"],
        correctIndex: 2,
      ),
      Question(
        title: "Science",
        question: "Which animal is known as the largest mammal?",
        options: ["Elephant", "Blue Whale", "Shark", "Giraffe"],
        correctIndex: 1,
      ),
      Question(
        title: "Science",
        question: "Which gas do plants release during photosynthesis?",
        options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"],
        correctIndex: 0,
      ),
      Question(
        title: "Science",
        question: "How many bones are there in an adult human body?",
        options: ["206", "150", "300", "180"],
        correctIndex: 0,
      ),
    ],
    "English": [
      Question(
        title: "English",
        question: "Which of these is a 'vowel'?",
        options: ["B", "M", "E", "Y"],
        correctIndex: 2,
      ),
      Question(
        title: "English",
        question: "What is the plural of 'Child'?",
        options: ["Childs", "Children", "Childrens", "Childes"],
        correctIndex: 1,
      ),
      Question(
        title: "English",
        question: "Identify the 'Verb' in: 'The cat runs fast.'",
        options: ["Cat", "Runs", "Fast", "The"],
        correctIndex: 1,
      ),
      Question(
        title: "English",
        question: "Which word is an 'Antonym' (opposite) of 'Hot'?",
        options: ["Warm", "Cold", "Boiling", "Sun"],
        correctIndex: 1,
      ),
      Question(
        title: "English",
        question: "Fill in the blank: 'I ___ going to the market.'",
        options: ["is", "am", "are", "be"],
        correctIndex: 1,
      ),
      Question(
        title: "English",
        question: "Which of these is spelled correctly?",
        options: ["Recieve", "Receive", "Receve", "Riceive"],
        correctIndex: 1,
      ),
      Question(
        title: "English",
        question: "What is a person who writes books called?",
        options: ["Actor", "Doctor", "Author", "Baker"],
        correctIndex: 2,
      ),
      Question(
        title: "English",
        question: "Choose the correct article: 'She ate ___ apple.'",
        options: ["a", "an", "the", "no article"],
        correctIndex: 1,
      ),
      Question(
        title: "English",
        question: "Which word is a 'Noun'?",
        options: ["Beautiful", "Quickly", "London", "Slept"],
        correctIndex: 2,
      ),
      Question(
        title: "English",
        question: "What is the past tense of 'Eat'?",
        options: ["Eaten", "Eated", "Ate", "Eating"],
        correctIndex: 2,
      ),
    ],

    "Indian History": [
      Question(
        title: "Indian History",
        question: "Who was the first Prime Minister of India?",
        options: [
          "Mahatma Gandhi",
          "Jawaharlal Nehru",
          "Sardar Patel",
          "Rajendra Prasad",
        ],
        correctIndex: 1,
      ),
      Question(
        title: "Indian History",
        question: "In which year did India gain independence?",
        options: ["1945", "1946", "1947", "1950"],
        correctIndex: 2,
      ),
      Question(
        title: "Indian History",
        question: "Who was known as the Father of the Nation in India?",
        options: [
          "Subhas Chandra Bose",
          "Jawaharlal Nehru",
          "Mahatma Gandhi",
          "Bhagat Singh",
        ],
        correctIndex: 2,
      ),
      Question(
        title: "Indian History",
        question: "Who founded the Maurya Empire?",
        options: ["Ashoka", "Chandragupta Maurya", "Harsha", "Akbar"],
        correctIndex: 1,
      ),
      Question(
        title: "Indian History",
        question: "Which Mughal emperor built the Taj Mahal?",
        options: ["Akbar", "Babur", "Shah Jahan", "Aurangzeb"],
        correctIndex: 2,
      ),
      Question(
        title: "Indian History",
        question: "Who was the last Mughal emperor of India?",
        options: ["Bahadur Shah Zafar", "Aurangzeb", "Akbar", "Humayun"],
        correctIndex: 0,
      ),
      Question(
        title: "Indian History",
        question: "Which movement was started by Mahatma Gandhi in 1942?",
        options: [
          "Non-Cooperation Movement",
          "Quit India Movement",
          "Civil Disobedience Movement",
          "Swadeshi Movement",
        ],
        correctIndex: 1,
      ),
      Question(
        title: "Indian History",
        question: "Who was the first President of India?",
        options: [
          "Dr. Rajendra Prasad",
          "Jawaharlal Nehru",
          "Sardar Patel",
          "Dr. B. R. Ambedkar",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "Indian History",
        question: "Who was known as the Iron Man of India?",
        options: [
          "Jawaharlal Nehru",
          "Sardar Vallabhbhai Patel",
          "Subhas Chandra Bose",
          "Bhagat Singh",
        ],
        correctIndex: 1,
      ),
      Question(
        title: "Indian History",
        question: "Who wrote the Indian National Anthem?",
        options: [
          "Rabindranath Tagore",
          "Bankim Chandra Chatterjee",
          "Sarojini Naidu",
          "Subhas Chandra Bose",
        ],
        correctIndex: 0,
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
        question: "Which of the following is an input device?",
        options: ["Monitor", "Keyboard", "Printer", "Speaker"],
        correctIndex: 1,
      ),

      Question(
        title: "Computer",
        question: "What does RAM stand for?",
        options: [
          "Random Access Memory",
          "Read Access Memory",
          "Run Access Memory",
          "Random Active Memory",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "Computer",
        question: "What does RAM stand for?",
        options: [
          "Random Access Memory",
          "Read Access Memory",
          "Run Access Memory",
          "Rapid Action Memory",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "Computer",
        question: "Which storage device is used to store data permanently?",
        options: ["RAM", "Cache", "Hard Disk", "Register"],
        correctIndex: 2,
      ),
      Question(
        title: "Computer",
        question: "Which device is used to control the pointer on the screen?",
        options: ["Mouse", "Printer", "Speaker", "Scanner"],
        correctIndex: 0,
      ),
      Question(
        title: "Computer",
        question: "Which software is used to browse the internet?",
        options: ["Browser", "Compiler", "Operating System", "Text Editor"],
        correctIndex: 0,
      ),
      Question(
        title: "Computer",
        question: "Which key is used to move to the next line while typing?",
        options: ["Shift", "Enter", "Tab", "Ctrl"],
        correctIndex: 1,
      ),
      Question(
        title: "Computer",
        question: "Which unit is used to measure computer memory?",
        options: ["Meter", "Byte", "Second", "Volt"],
        correctIndex: 1,
      ),
      Question(
        title: "Computer",
        question:
            "Which of the following is an example of an operating system?",
        options: [
          "Microsoft Word",
          "Google Chrome",
          "Windows 10",
          "Adobe Photoshop",
        ],
        correctIndex: 2,
      ),
    ],

    "Sports": [
      Question(
        title: "Sports",
        question:
            "How many players are there in a football (soccer) team on the field?",
        options: ["9", "10", "11", "12"],
        correctIndex: 2,
      ),
      Question(
        title: "Sports",
        question: "Which country won the Cricket World Cup in 2011?",
        options: ["Australia", "India", "England", "Pakistan"],
        correctIndex: 1,
      ),
      Question(
        title: "Sports",
        question: "Which sport uses a racket and shuttlecock?",
        options: ["Tennis", "Badminton", "Table Tennis", "Squash"],
        correctIndex: 1,
      ),
      Question(
        title: "Sports",
        question: "How many players are there in a cricket team?",
        options: ["9", "10", "11", "12"],
        correctIndex: 2,
      ),
      Question(
        title: "Sports",
        question: "Which sport is associated with Wimbledon?",
        options: ["Cricket", "Football", "Tennis", "Hockey"],
        correctIndex: 2,
      ),
      Question(
        title: "Sports",
        question: "Which country hosted the 2016 Summer Olympics?",
        options: ["China", "Brazil", "Japan", "UK"],
        correctIndex: 1,
      ),
      Question(
        title: "Sports",
        question: "In which sport is the term 'checkmate' used?",
        options: ["Chess", "Tennis", "Football", "Hockey"],
        correctIndex: 0,
      ),
      Question(
        title: "Sports",
        question: "Which Indian player is known as the 'God of Cricket'?",
        options: [
          "Virat Kohli",
          "MS Dhoni",
          "Sachin Tendulkar",
          "Rohit Sharma",
        ],
        correctIndex: 2,
      ),
      Question(
        title: "Sports",
        question: "How many rings are there in the Olympic symbol?",
        options: ["4", "5", "6", "7"],
        correctIndex: 1,
      ),
      Question(
        title: "Sports",
        question: "Which sport uses a hoop and a ball?",
        options: ["Basketball", "Volleyball", "Tennis", "Baseball"],
        correctIndex: 0,
      ),
    ],

    "Physics": [
      Question(
        title: "Physics",
        question: "What is the SI unit of force?",
        options: ["Newton", "Joule", "Watt", "Pascal"],
        correctIndex: 0,
      ),

      Question(
        title: "Physics",
        question: "What is the SI unit of speed?",
        options: ["Kilometer", "Meter per second", "Second", "Meter"],
        correctIndex: 1,
      ),

      Question(
        title: "Physics",
        question: "Newton's First Law of Motion is also commonly known as the?",
        options: [
          "Law of Universal Gravitation",
          "Law of Action and Reaction",
          "Law of Acceleration",
          "Law of Inertia",
        ],
        correctIndex: 3,
      ),

      Question(
        title: "Physics",
        question:
            "If the resultant force acting on a body of constant mass is zero, the body's momentum is?",
        options: ["Increasing", "Decreasing", "Always zero", "Constant"],
        correctIndex: 3,
      ),

      Question(
        title: "Physics",
        question: "Which of the following is a unit of angular velocity?",
        options: [
          "Radian",
          "Radian per second (rad/s)",
          "Meter per second",
          "Newton",
        ],
        correctIndex: 1,
      ),

      Question(
        title: "Physics",
        question: "The energy possessed by a body due to its motion is called?",
        options: ["Kinetic Energy", "Potential Energy", "Joule", "Watt"],
        correctIndex: 0,
      ),

      Question(
        title: "Physics",
        question:
            "What is the escape velocity required for a body to leave Earth's surface?",
        options: ["9.8 km/s", "15.2 km/s", "10.3 km/s", "11.2 km/s"],
        correctIndex: 3,
      ),
      Question(
        title: "Physics",
        question:
            "What form of energy does a plant store when light is transformed during photosynthesis?",
        options: [
          "Light Energy",
          "Heat Energy",
          "Chemical Energy",
          "Mechanical Energy",
        ],
        correctIndex: 2,
      ),
      Question(
        title: "Physics",
        question:
            "Which particle was discovered by J.J. Thomson in 1897 using a cathode ray tube?",
        options: ["Electron", "Proton", "Neutron", "Photon"],
        correctIndex: 0,
      ),
      Question(
        title: "Physics",
        question:
            "The phenomenon of light bending as it passes from one medium to another is called?",
        options: ["Reflection", "Refraction", "Diffraction", "Interference"],
        correctIndex: 1,
      ),
    ],

    "Art & Drawing": [
      Question(
        title: "Art & Drawing",
        question: "Who painted the famous artwork 'Mona Lisa'?",
        options: [
          "Vincent Van Gogh",
          "Leonardo da Vinci",
          "Pablo Picasso",
          "Michelangelo",
        ],
        correctIndex: 1,
      ),
      Question(
        title: "Art & Drawing",
        question: "Which colors are known as primary colors?",
        options: [
          "Red, Blue, Yellow",
          "Green, Orange, Purple",
          "Black, White, Grey",
          "Pink, Brown, Blue",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "Art & Drawing",
        question: "Which tool is commonly used for sketching?",
        options: ["Brush", "Pencil", "Marker", "Crayon"],
        correctIndex: 1,
      ),
      Question(
        title: "Art & Drawing",
        question: "What do you get when you mix red and yellow colors?",
        options: ["Green", "Orange", "Purple", "Brown"],
        correctIndex: 1,
      ),
      Question(
        title: "Art & Drawing",
        question: "Which material is commonly used for watercolor painting?",
        options: ["Canvas", "Watercolor Paper", "Wood", "Plastic Sheet"],
        correctIndex: 1,
      ),
      Question(
        title: "Art & Drawing",
        question: "Which famous artist cut off part of his ear?",
        options: [
          "Vincent Van Gogh",
          "Pablo Picasso",
          "Leonardo da Vinci",
          "Claude Monet",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "Art & Drawing",
        question:
            "What is the art of making images with pencils, pens, or charcoal called?",
        options: ["Painting", "Drawing", "Sculpture", "Photography"],
        correctIndex: 1,
      ),
      Question(
        title: "Art & Drawing",
        question: "Which color is made by mixing blue and yellow?",
        options: ["Green", "Purple", "Orange", "Pink"],
        correctIndex: 0,
      ),
      Question(
        title: "Art & Drawing",
        question: "Which surface is commonly used for painting?",
        options: ["Canvas", "Metal", "Glass", "Stone"],
        correctIndex: 0,
      ),
      Question(
        title: "Art & Drawing",
        question: "What is shading used for in drawing?",
        options: [
          "Adding color",
          "Creating depth and dimension",
          "Cutting paper",
          "Making lines straight",
        ],
        correctIndex: 1,
      ),
    ],

    "Programming": [
      Question(
        title: "Programming",
        question: "What is a variable in programming?",
        options: [
          "A fixed value",
          "A container to store data",
          "A loop statement",
          "A type of function",
        ],
        correctIndex: 1,
      ),
      Question(
        title: "Programming",
        question:
            "Which keyword is used to declare a variable in many languages like JavaScript?",
        options: ["loop", "var", "print", "class"],
        correctIndex: 1,
      ),
      Question(
        title: "Programming",
        question:
            "What will be the output?\n if x = 5 \n if(x > 3){\n\tprint('Hello');\n}?",
        options: ["Nothing", "Hello", "Error", "5"],
        correctIndex: 1,
      ),
      Question(
        title: "Programming",
        question: "Which loop is used when the number of iterations is known?",
        options: ["while loop", "do-while loop", "for loop", "switch"],
        correctIndex: 2,
      ),
      Question(
        title: "Programming",
        question: "Which operator is used to compare two values?",
        options: ["=", "==", "++", "&&"],
        correctIndex: 1,
      ),
      Question(
        title: "Programming",
        question:
            "What will be the output of: for(int i=0; i<3; i++) print(i);",
        options: ["012", "123", "321", "Error"],
        correctIndex: 0,
      ),
      Question(
        title: "Programming",
        question: "Which statement is used to make decisions in programming?",
        options: ["loop", "if", "break", "print"],
        correctIndex: 1,
      ),
      Question(
        title: "Programming",
        question: "What does the condition (a != b) mean?",
        options: [
          "a is equal to b",
          "a is greater than b",
          "a is not equal to b",
          "a is less than b",
        ],
        correctIndex: 2,
      ),
      Question(
        title: "Programming",
        question:
            "What will be the final value of x if x starts at 10 and decreases until x > 7?",
        options: ["10", "8", "7", "6"],
        correctIndex: 2,
      ),
      Question(
        title: "Programming Basics",
        question: "Which data type is used to store text?",
        options: ["int", "string", "float", "boolean"],
        correctIndex: 1,
      ),
    ],

    "Chemistry": [
      Question(
        title: "Chemistry",
        question: "What is the chemical symbol for water?",
        options: ["O2", "H2O", "CO2", "NaCl"],
        correctIndex: 1,
      ),
      Question(
        title: "Chemistry",
        question: "Which gas do plants absorb from the atmosphere?",
        options: ["Oxygen", "Carbon Dioxide", "Nitrogen", "Hydrogen"],
        correctIndex: 1,
      ),
      Question(
        title: "Chemistry",
        question: "What is the pH value of pure water?",
        options: ["5", "6", "7", "8"],
        correctIndex: 2,
      ),
      Question(
        title: "Chemistry",
        question: "Which element has the chemical symbol 'O'?",
        options: ["Gold", "Oxygen", "Silver", "Iron"],
        correctIndex: 1,
      ),
      Question(
        title: "Chemistry",
        question: "Which gas is known as laughing gas?",
        options: ["Nitrous Oxide", "Carbon Monoxide", "Methane", "Hydrogen"],
        correctIndex: 0,
      ),
      Question(
        title: "Chemistry",
        question: "What is the main gas found in the air we breathe?",
        options: ["Oxygen", "Nitrogen", "Carbon Dioxide", "Helium"],
        correctIndex: 1,
      ),
      Question(
        title: "Chemistry",
        question: "Which metal is liquid at room temperature?",
        options: ["Mercury", "Iron", "Copper", "Aluminum"],
        correctIndex: 0,
      ),
      Question(
        title: "Chemistry",
        question: "What is the chemical formula of carbon dioxide?",
        options: ["CO", "CO2", "C2O", "O2C"],
        correctIndex: 1,
      ),
      Question(
        title: "Chemistry",
        question: "Which acid is found in lemon?",
        options: [
          "Sulfuric acid",
          "Nitric acid",
          "Citric acid",
          "Hydrochloric acid",
        ],
        correctIndex: 2,
      ),
      Question(
        title: "Chemistry",
        question: "What is the smallest unit of an element?",
        options: ["Molecule", "Atom", "Cell", "Compound"],
        correctIndex: 1,
      ),
    ],
    "General Knowledge": [
      Question(
        title: "Indian General Knowledge",
        question: "Who is known as the 'Iron Man of India'?",
        options: [
          "Sardar Vallabhbhai Patel",
          "Jawaharlal Nehru",
          "Mahatma Gandhi",
          "Subhas Chandra Bose",
        ],
        correctIndex: 0,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "Which Indian state has the longest coastline?",
        options: ["Maharashtra", "Tamil Nadu", "Gujarat", "Andhra Pradesh"],
        correctIndex: 2,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "What is the national heritage animal of India?",
        options: ["Tiger", "Elephant", "Lion", "Rhicoceros"],
        correctIndex: 1,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "In which year did India win its first Cricket World Cup?",
        options: ["1975", "1987", "1983", "2011"],
        correctIndex: 2,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "Which city is known as the 'Silicon Valley of India'?",
        options: ["Hyderabad", "Pune", "Mumbai", "Bengaluru"],
        correctIndex: 3,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "Who was the first woman Prime Minister of India?",
        options: [
          "Pratibha Patil",
          "Indira Gandhi",
          "Sarojini Naidu",
          "Sushma Swaraj",
        ],
        correctIndex: 1,
      ),
      Question(
        title: "Indian General Knowledge",
        question:
            "The classical dance form 'Kathakali' originated in which state?",
        options: ["Kerala", "Karnataka", "Tamil Nadu", "Odisha"],
        correctIndex: 0,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "Which is the highest civilian award in India?",
        options: [
          "Padma Vibhushan",
          "Param Vir Chakra",
          "Bharat Ratna",
          "Sahitya Akademi Award",
        ],
        correctIndex: 2,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "Which planet is known as the 'Red Planet'?",
        options: ["Venus", "Mars", "Saturn", "Jupiter"],
        correctIndex: 1,
      ),
      Question(
        title: "Indian General Knowledge",
        question: "The 'Hawa Mahal' is located in which Indian city?",
        options: ["Jodhpur", "Udaipur", "Jaipur", "Bikaner"],
        correctIndex: 2,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();

    if (widget.useRandomSelection) {
      final random = Random();
      final mixedQuestions =
          allQuestions.values.expand((items) => items).toList()
            ..shuffle(random);
      final count = mixedQuestions.length < widget.randomQuestionCount
          ? mixedQuestions.length
          : widget.randomQuestionCount;
      questions = mixedQuestions.take(count).toList();
    } else {
      questions = allQuestions[widget.title] ?? [];
    }

    if (questions.isNotEmpty) {
      restartTimer();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void autoNextQuestion() {
    recordAnswer();

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
    _isShowingResult = false;

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
        if (!mounted) return;
        setState(() {
          isTimeUp = true;
        });

        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted || _isShowingResult) return;
          autoNextQuestion();
        });
      } else {
        if (!mounted) return;
        setState(() {
          seconds--;
        });
      }
    });
  }

  void showResult() async {
    if (_isShowingResult) return;
    _isShowingResult = true;
    timer?.cancel();

    if (!_isSaved) {
      await UserCache.recordAttempt(
        category: widget.title,
        score: score,
        total: questions.length,
      );
      await UserCache.saveQuizAttempt(
        attempt: {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'subject': widget.title,
          'date': DateTime.now().toIso8601String(),
          'totalQuestions': questions.length,
          'correctAnswers': score,
          'questions': answered
              .map(
                (q) => {
                  'questionNo': answered.indexOf(q) + 1,
                  'question': q.question,
                  'correctAnswer': q.correctAnswer,
                  'selectedAnswer': q.userAnswer,
                  'isCorrect': q.userAnswer == q.correctAnswer,
                },
              )
              .toList(),
        },
      );
      _isSaved = true;
    }

    showDialog(
      // ignore: use_build_context_synchronously
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
              timer?.cancel();
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ReviewScreen(
    //       category: widget.title,
    //       answered: answered, // ✅ PASS REAL DATA
    //     ),
    //   ),
    // );
  }

  Future<void> saveCurrentQuiz() async {
    if (_isQuizSaved) {
      _toast("Quiz already saved");
    } else {
      _toast('Quiz saved successfully');
    }
    await UserCache.saveQuiz(
      title: widget.title,
      useRandomSelection: widget.useRandomSelection,
      randomQuestionCount: widget.randomQuestionCount,
    );

    if (!mounted) return;

    setState(() {
      _isQuizSaved = true;
    });
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

    recordAnswer();

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
    double progressValue = questions.isEmpty
        ? 0
        : (currentIndex + 1) / questions.length;
    if (questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: const Center(
          child: Text(
            "No questions available",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }

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
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: saveCurrentQuiz,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.border,
                    ),
                    icon: Icon(
                      _isQuizSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                    ),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isSelected ? Colors.blue : Colors.white12,
              child: Text(
                String.fromCharCode(65 + index),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  questions[currentIndex].options[index],
                  maxLines: 4,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 20,
              child: isSelected
                  ? const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.blue,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppColors.text)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.border),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
