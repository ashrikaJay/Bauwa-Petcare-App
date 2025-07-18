import 'package:flutter/material.dart';
import 'signup_screen.dart';

import 'package:bauwa/core/widgets/home_nav.dart';
import 'package:bauwa/core/widgets/rounded_textfield.dart';
import 'package:bauwa/core/widgets/google_sign_in_button.dart';
import 'package:bauwa/core/widgets/nickname_prompt.dart';

import 'package:bauwa/controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //final AuthController _authController = AuthController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  bool _validateInputs(String email, String password) {
    final RegExp emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,15}$');

    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      _showError("Please enter a valid email address.");
      return false;
    }
    if (password.isEmpty) {
      _showError("Please enter your password.");
      return false;
    }
    if (password.length < 6) {
      _showError("Password must be at least 6 characters long.");
      return false;
    }
    return true;
  }

  /// Log in with Email & Password
  void _login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (!_validateInputs(email, password)) return;
    setState(() => _isLoading = true);

    try {
      await AuthController.instance.login(email, password);
      _navigateToHome();
    } catch (e) {
      _showError("Login failed: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Sign in with Google
  void _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      //final user = await _authController.signInWithGoogle();
      final user = await AuthController.instance.signInWithGoogle();
      if (user != null) {
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

  /// Prompt user for a nickname (if missing)
  Future<String?> _promptForNickname() async {
    TextEditingController nicknameController = TextEditingController();
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
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

  /// Navigate to Home Screen
  void _navigateToHome() {
    debugPrint("Navigating to HomeScreen...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spring into Action!")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 120),
              Image.asset('assets/icons/login-greeting.png',
                  width: 200, height: 200),
              const SizedBox(height: 10),
              //_buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress),
              RoundedTextField(controller: emailController, label: "Email"),
              const SizedBox(height: 20),
              RoundedTextField(
                  controller: passwordController,
                  label: "Password",
                  obscureText: true),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                // disable button when loading
                style: ElevatedButton.styleFrom(
                  //backgroundColor: Colors.blueGrey[700],
                  backgroundColor: Color(0xFF8C5E35),
                  //backgroundColor: Color(0xE82C0D05),
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
                        "Sign in",
                        style: TextStyle(color: Colors.white),
                      ),
              ),

              const SizedBox(height: 20),

              // Google Sign-In Button
              GoogleSignInButton(onPressed: _signInWithGoogle),
              const SizedBox(height: 20),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignUpScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Sign Up!",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
