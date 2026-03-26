import 'package:flutter/material.dart';
import 'package:quiz/Screens/Login_Screen.dart';
import 'package:quiz/Screens/ProfileScreen.dart';
import 'package:quiz/Screens/UserCache.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserCache.init();
  final loggedIn = await UserCache.isLoggedIn();
  runApp(MyApp(isLoggedIn: loggedIn));
}


class MyApp extends StatelessWidget {
  const MyApp({super.key, this.isLoggedIn = false});

  final bool isLoggedIn;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brain Byte',
      theme: ThemeData.dark(),
      home: isLoggedIn ? MainScreen() : const LoginScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Screen'),
      ),
      body: const Center(
        child: Text('This is the test screen.',style: TextStyle(color: Colors.white,fontSize: 25),),
      ),
    );
  }

}
