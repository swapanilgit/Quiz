import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController searchController = TextEditingController();

  List<String> categories = [
    "Science",
    "Chemistry",
    "History",
    "Indian History",
    "Computer",
    "Sports",
    "Programming Basics",
    "Arts & Drawing"
  ];

  List<String> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    filteredCategories = categories;
  }

  void searchCategory(String query) {
    final results = categories.where((category) {
      return category.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredCategories = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: searchCategory,
          decoration: const InputDecoration(
            hintText: "Search category...",
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredCategories[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}