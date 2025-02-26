import 'package:flutter/material.dart';
import 'package:bauwa/nav/home_screen.dart';
import 'package:bauwa/screens/signup_screen.dart';
import 'package:bauwa/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bauwa Petcare App',
      //home: DashboardPage(),
      //home: const HomeScreen(),
      //home: const SignUpScreen(),
      home: const LoginScreen(),
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
            color: Color(0xE82C0D05),
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontFamily: '',
            )
          )
      ),

    );
  }
}

