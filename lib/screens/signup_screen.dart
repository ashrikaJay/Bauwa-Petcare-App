import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import 'package:bauwa/nav/home_screen.dart'; // Redirect after login

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  //_SignUpScreenState createState() => _SignUpScreenState();
  State<SignUpScreen>  createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isGoogleSignIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  /// Create an account with email & password
  void _signUp() async {
    setState(() => _isLoading = true);

    String nickname = nicknameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (nickname.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user != null) {
        await _saveUserData(user.uid, nickname, email, null);
        _navigateToHome();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Sign in with Google & prompt nickname input
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

        /*if (userDoc.exists) {
          _navigateToHome(); // User already has an account
        } else {
          setState(() => _isGoogleSignIn = true);
        }*/
        if (!userDoc.exists || !userDoc.data().toString().contains('nickname')) {
          // Prompt user to enter a nickname
          String? nickname = await _promptForNickname();

          if (nickname != null && nickname.isNotEmpty) {
            await _saveUserData(user.uid, nickname, user.email ?? "", user.photoURL);
            debugPrint("Nickname saved: $nickname");
          } else {
            _showError("Nickname is required to continue.");
            return;
          }
        }

        debugPrint("User authentication successful. Navigating to HomeScreen...");
        _navigateToHome();

      }
    } catch (e) {
      _showError("Google Sign-In Error: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Save user details to Firestore
  Future<void> _saveUserData(String userId, String nickname, String email, String? photoUrl) async {
    await _firestore.collection('users').doc(userId).set({
      'nickname': nickname,
      'email': email,
      'profilePic': photoUrl,
    });
  }

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
  /// Show error messages using `ScaffoldMessenger`
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
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/together.png', width: 200, height: 200),
            _buildTextField(nicknameController, "Nickname"),
            const SizedBox(height: 10),
            _buildTextField(emailController, "Email",
                keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _buildTextField(passwordController, "Password", obscureText: true),
            const SizedBox(height: 10),
            _buildTextField(confirmPasswordController, "Confirm Password",
                obscureText: true),
            const SizedBox(height: 20),

            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _signUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                minimumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                  "Sign Up", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),

            // Circular Google Sign-In Button
            ElevatedButton(
              onPressed: _signInWithGoogle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(), // Circular button
                padding: const EdgeInsets.all(12), // Adjust padding for size
                elevation: 3, // Slight elevation for a modern look
              ),
              child: Image.asset(
                'assets/icons/google-icon.png',
                height: 40, width: 40, // Adjust size of Google logo
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.account_circle, size: 40, color: Colors.blue);
                },
              ),
            ),

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

