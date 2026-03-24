
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
    {
      "title": "Indian History",
      "icon": Icons.history_edu,
      "color": Colors.orange,
    },
    {"title": "Physics", "icon": Icons.science, "color": Colors.purple},
    {
      "title": "Chemistry",
      "icon": Icons.science_outlined,
      "color": Colors.purple,
    },
    {"title": "Programming", "icon": Icons.code, "color": Colors.purple},
    {"title": "Computer", "icon": Icons.memory, "color": Colors.purple},
    {"title": "Art & Drawing", "icon": Icons.palette, "color": Colors.red},
    {"title": "Sports", "icon": Icons.sports_esports, "color": Colors.green},
  ];

  List<Map<String, dynamic>> filteredCategories = [];

  // int _selectedIndex = 0;

  // final List<String> bottomLabels = ["Home", "Search", "Profile"];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });

  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text("${bottomLabels[index]} Clicked"),
  //       duration: const Duration(milliseconds: 500),
  //     ),
  //   );
  // }

  void searchCategory(String query) {
    final results = allCategories.where((category) {
      return category["title"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCategories = results;
    });

    (value) {
      setState(() {
        searchCategory(value);
      });
    };
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: searchController,
                        onChanged: searchCategory,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          icon: const Icon(Icons.search, color: Colors.white54),
                          hintText: "Search topics, quizzes or users...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          border: InputBorder.none,

                          /// 👇 Clear button
                          suffixIcon: searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    searchController.clear();
                                    searchCategory(""); // reset search
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
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
                  children: [
                    ActionChip(
                      label: const Text("WEEKLY SPECIAL"),
                      backgroundColor: Colors.blue,
                      labelStyle: const TextStyle(color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuizScreen(
                              "Weekly Special",
                              useRandomSelection: true,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Cosmic Wonders",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
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
    );
  }
}
