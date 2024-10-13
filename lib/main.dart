import 'package:flutter/material.dart';
import 'screens/login_choice_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AnimalRescueApp());
}

class AnimalRescueApp extends StatelessWidget {
  const AnimalRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Street Animal Rescue',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: LoginChoiceScreen(),
      debugShowCheckedModeBanner: false, // This removes the debug tag
    );
  }
}
