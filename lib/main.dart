import 'package:flutter/material.dart';
// import 'package:quiz/Screens/HomeScreen.dart';
import 'package:quiz/Screens/ProfileScreen.dart';
// import 'package:quiz/Screens/QuizScreen.dart';
// import 'Screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Byte',
      theme: ThemeData.dark(),
      home: MainScreen(),
    );
  }
}
