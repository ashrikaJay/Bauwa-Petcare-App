import 'package:flutter/material.dart';

import 'package:bauwa/core/widgets/home_nav.dart'; // Redirect after login
import 'package:bauwa/core/widgets/rounded_textfield.dart';
import 'package:bauwa/core/widgets/google_sign_in_button.dart';
import 'package:bauwa/core/widgets/nickname_prompt.dart';

import 'package:bauwa/controllers/auth_controller.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  /// Create an account with email & password
  void _signUp() async {
    setState(() => _isLoading = true);

    String nickname = nicknameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (nickname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError("All fields are required!");
      setState(() => _isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      _showError("Passwords do not match!");
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await AuthController.instance
          .signUpWithEmailAndPassword(email, password);
      if (user != null) {
        await AuthController.instance.saveUserData(
          userId: user.uid,
          nickname: nickname,
          email: email,
          photoUrl: null,
        );
        _navigateToHome();
      }
    } catch (e) {
      _showError("Sign Up failed: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Sign in with Google & prompt nickname input
  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthController.instance.signInWithGoogle();
      if (user != null) {
        //final hasNickname = await AuthController.instance.hasNickname(user.uid);
        bool hasNickname = await AuthController.instance.hasNickname(user.uid);
        if (!hasNickname) {
          String? nickname = await _promptForNickname();
          if (nickname != null && nickname.isNotEmpty) {
            await AuthController.instance.saveUserData(
              userId: user.uid,
              nickname: nickname,
              email: user.email ?? "",
              photoUrl: user.photoURL,
            );
          } else {
            _showError("Nickname is required to continue.");
            return;
          }
        }
        _navigateToHome();
      }
    } catch (e) {
      _showError("Google Sign-In failed: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _promptForNickname() async {
    TextEditingController nicknameController = TextEditingController();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent dismissing without input
      builder: (context) {
        return NicknamePrompt(
          controller: nicknameController,
          onSave: () {
            String nickname = nicknameController.text.trim();
            if (nickname.isNotEmpty) {
              Navigator.of(context).pop(nickname);
            }
          },
        );
      },
    );
  }

  /// Navigate to Home Screen
  void _navigateToHome() {
    debugPrint("Navigating to HomeScreen...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  /*void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }*/

  /// Show error messages
  void _showError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Leave your Pawprint!")),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          color: const Color(0xFFCCB69A),
          //color: const Color(0xFFCBB293),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Image.asset('assets/together.png', width: 200, height: 200),
                const SizedBox(height: 20),
                RoundedTextField(
                    controller: nicknameController, label: "Nickname"),
                const SizedBox(height: 10),
                RoundedTextField(
                    controller: emailController,
                    label: "Email",
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                RoundedTextField(
                    controller: passwordController,
                    label: "Password",
                    obscureText: true),
                const SizedBox(height: 10),
                RoundedTextField(
                    controller: confirmPasswordController,
                    label: "Confirm Password",
                    obscureText: true),
                const SizedBox(height: 30),

                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  // disable button when loading
                  style: ElevatedButton.styleFrom(
                    //backgroundColor: Color(0xFF3D261C),
                    //backgroundColor: Color(0xE84D3434),
                    backgroundColor: Color(0xFF8C5E35),
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Sign up",
                          style: TextStyle(color: Colors.white),
                        ),
                ),

                const SizedBox(height: 20),

                // Google Sign-In Button
                GoogleSignInButton(onPressed: _signInWithGoogle),

                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Already have an account? Sign In!",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
