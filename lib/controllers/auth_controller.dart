import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController {
  /// Using Singleton: only one instance of AuthController exists in the entire app
  AuthController._privateConstructor();
  static final AuthController _instance = AuthController._privateConstructor();
  static AuthController get instance => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Login with Email and Password
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  /// Sign Up with Email and Password (signup: for adv token handling or re-authentication)
  /*Future<UserCredential> signup(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }*/

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    return userCredential.user;
  }

  /// Google Sign-In
  Future<User?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  /// Save user data to Firestore
  Future<void> saveUserData({
    required String userId,
    required String nickname,
    required String email,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'nickname': nickname,
      'email': email,
      'profilePic': photoUrl,
    });
  }

  /// Check if user has nickname
  Future<bool> hasNickname(String userId) async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
    return userDoc.exists && userDoc.data().toString().contains('nickname');
  }

  Future<Map<String, dynamic>?> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return {
        'nickname': userDoc['nickname'] ?? '',
        'photoUrl': user.photoURL,
        'email': user.email,
      };
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

}