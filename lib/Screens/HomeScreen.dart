// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:quiz/Screens/QuizScreen.dart';
import 'package:quiz/Screens/buildCategoryCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    filteredCategories = allCategories;
  }

  TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> allCategories = [
    {"title": "Science", "icon": Icons.science, "color": Colors.blue},
    {"title": "Indian History","icon": Icons.history_edu,"color": Colors.orange,},
    {"title": "Physics", "icon": Icons.science, "color": Colors.purple},
    {"title": "Chemistry","icon": Icons.science_outlined,"color": Colors.purple,},
    {"title": "Programming", "icon": Icons.code, "color": Colors.purple},
    {"title": "Computer", "icon": Icons.memory, "color": Colors.purple},
    {"title": "Art & Drawing", "icon": Icons.palette, "color": Colors.red},
    {"title": "Sports", "icon": Icons.sports_esports, "color": Colors.green},
    {"title": "GeneralKnowledge", "icon": Icons.school, "color": const Color.fromARGB(255, 112, 87, 87)},
  ];

  List<Map<String, dynamic>> filteredCategories = [];

  int _selectedIndex = 0;

  final List<String> bottomLabels = ["Home", "Rankings", "Profile"];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${bottomLabels[index]} Clicked"),
        duration: const Duration(milliseconds: 500),
      ),
    );
  }

  void searchCategory(String query) {
    final results = allCategories.where((category) {
      return category["title"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCategories = results;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              /// Top Welcome Text
              const Text(
                "Welcome back, Alex!",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),

              const SizedBox(height: 8),

              const Text(
                "Explore Quizzes",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: searchCategory,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search, color: Colors.white54),
                    hintText: "Search topics, quizzes or users...",
                    hintStyle: TextStyle(color: Colors.white54),
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Featured Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Featured Challenges",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("See All Clicked")),
                      );
                    },
                    child: const Text("See All"),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              /// Featured Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Chip(
                      label: Text("WEEKLY SPECIAL"),
                      backgroundColor: Colors.blue,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Cosmic Wonders",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Test your space knowledge",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// Categories Header
              const Text(
                "Categories",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// Categories Grid
              // GridView.count(
              //   crossAxisCount: 2,
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   crossAxisSpacing: 15,
              //   mainAxisSpacing: 15,
              //   childAspectRatio: 1.1,
              //   children: [
              //     buildCategoryCard(
              //       icon: Icons.science,
              //       title: "Science",

              //       color: Colors.blue,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen('Science'),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),

              //     buildCategoryCard(
              //       icon: Icons.history_edu,
              //       title: "Indian History",
              //       color: Colors.orange,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen("Indian History"),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),

              //     buildCategoryCard(
              //       icon: Icons.science,
              //       title: "Physics",
              //       color: Colors.purple,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen("Physics"),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),

              //     buildCategoryCard(
              //       icon: Icons.science_outlined,
              //       title: "Chemistry",
              //       color: Colors.purple,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen("Chemistry"),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),

              //     buildCategoryCard(
              //       icon: Icons.code,
              //       title: "Programming",
              //       color: Colors.purple,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen("Programming"),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),

              //     buildCategoryCard(
              //       icon: Icons.memory,
              //       title: "Computer",
              //       color: Colors.purple,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen("Computer"),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),

              //     buildCategoryCard(
              //       icon: Icons.palette,
              //       title: "Art & Drawing",
              //       color: Colors.red,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen("Art & Drawing"),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),
              //     buildCategoryCard(
              //       icon: Icons.sports_esports,
              //       title: "Sports",
              //       color: Colors.green,
              //       onTap: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const QuizScreen("Sports"),
              //           ),
              //         );
              //       },
              //       quizCount: '',
              //     ),
              //   ],
              // ),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.1,
                children: filteredCategories.map((category) {
                  return buildCategoryCard(
                    
                    icon: category["icon"],
                    title: category["title"],
                    color: category["color"],
                    quizCount: '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(category["title"]),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),

      /// Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0F172A),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Rankings",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
