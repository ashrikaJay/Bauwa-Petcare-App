import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart'; // Ensure correct import
import 'package:bauwa/nav/home_screen.dart'; // Redirect after login

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  /// Log in with Email & Password
  void _login() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        debugPrint("Login successful");
        _navigateToHome();
      }
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return; // User canceled Google Sign-In
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Check if user exists in Firestore
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists || !userDoc.data().toString().contains('nickname')) {
          // Prompt for nickname if missing
          String? nickname = await _promptForNickname();
          if (nickname != null && nickname.isNotEmpty) {
            await _saveUserData(user.uid, nickname, user.email ?? "", user.photoURL);
          } else {
            _showError("Nickname is required to continue.");
            return;
          }
        }

        debugPrint("Google Sign-In successful");
        _navigateToHome();
      }
    } catch (e) {
      _showError("Google Sign-In Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Prompt user for a nickname (if missing)
  Future<String?> _promptForNickname() async {
    TextEditingController nicknameController = TextEditingController();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false, // Prevent dismissing without input
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Your Nickname"),
          content: TextField(
            controller: nicknameController,
            decoration: const InputDecoration(hintText: "Enter nickname"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close without saving
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                String nickname = nicknameController.text.trim();
                if (nickname.isNotEmpty) {
                  Navigator.of(context).pop(nickname); // Return nickname
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  /// Save user details to Firestore
  Future<void> _saveUserData(String userId, String nickname, String email, String? photoUrl) async {
    await _firestore.collection('users').doc(userId).set({
      'nickname': nickname,
      'email': email,
      'profilePic': photoUrl,
    });
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
      appBar: AppBar(title: const Text("Login")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 80),
            Image.asset('assets/icons/login-greeting.png', width: 200, height: 200),
            const SizedBox(height: 10),
            _buildTextField(emailController, "Email", keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(passwordController, "Password", obscureText: true),
            const SizedBox(height: 40),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // Google Sign-In Button
            ElevatedButton(
              onPressed: _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(), // Circular button
                padding: const EdgeInsets.all(12),
                elevation: 3,
              ),
              child: Image.asset(
                'assets/icons/google-icon.png',
                height: 40, width: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.account_circle, size: 40, color: Colors.blue);
                },
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
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
      ),//add the syntax from here
    );
  }

  /// Common function for building text fields
  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
