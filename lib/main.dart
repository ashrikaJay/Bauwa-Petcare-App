import 'package:flutter/material.dart';
import 'package:bauwa/view/auth/login_screen.dart';
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
      title: 'Bauwa Pet Care App',
      home: const LoginScreen(),
      theme: ThemeData(
          //scaffoldBackgroundColor: const Color(0xFFE0E6EF),
          scaffoldBackgroundColor: const Color(0xFFD9D1C7),
          //scaffoldBackgroundColor: const Color(0xFFCBE1EE),
          appBarTheme: const AppBarTheme(
            //color: Color(0xE82C0D05),
            color: Color(0xFF8C5E35),
            centerTitle: true,
            titleTextStyle: TextStyle(
              //color: Color(0xFFDCD9D3),
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w500,
              fontFamily: '',
            ),
           iconTheme: IconThemeData(
            color: Color(0xFFDCD9D3),
          ),
          ),
      ),

    );
  }
}

