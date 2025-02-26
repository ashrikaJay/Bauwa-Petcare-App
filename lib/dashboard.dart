import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:bauwa/screens/login_screen.dart';
import 'package:bauwa/nav/drawer.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _nickname = "User"; // Default placeholder
  String _currentDate = "";
  String? _profilePicUrl;
  String _email = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _updateDate();
  }

  /// Fetch nickname and profile picture from Firebase
  void _fetchUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        _profilePicUrl = user.photoURL; // Google Profile Picture
        _email = user.email ?? "No Email";
      });

      // Fetch additional user data (nickname) from Firestore if available
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc['nickname'] != null) {
        setState(() {
          _nickname = userDoc['nickname']; // Firestore nickname
        });
      }
    }
  }

  // Update current date dynamically
  void _updateDate() {
    setState(() {
      _currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    });
  }

  // Logout function
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to Login
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //drawer: _buildDrawer(),
      drawer: CustomDrawer(
        nickname: _nickname,
        email: _email,
        profilePicUrl: _profilePicUrl,
        onLogout: _logout, // Pass logout function
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greetings Section
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hello, $_nickname!", //
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(_currentDate, //
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),

                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer(); // Opens the drawer when clicking profile picture
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: _profilePicUrl != null
                        ? NetworkImage(_profilePicUrl!)
                        : const AssetImage('assets/dogs/dachshund.png.png'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Pet Profiles Section
            const Text('Your Pets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  PetCard(name: 'Angelina', imageUrl: 'assets/dogs/dachshund.png.png'),
                  PetCard(name: 'Cody', imageUrl: 'assets/dogs/black-labrador-cody.png'),
                  PetCard(name: 'Ally', imageUrl: 'assets/dogs/dachshund-brown-ally.png.png'),
                  PetCard(name: 'Comet', imageUrl: 'assets/cats/jp-cat-bobtail-comet.png.png'),

                ],
              ),
            ),

            const SizedBox(height: 20),

            // Upcoming Appointments Section
            const Text('Upcoming Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Vet Visit - Angelina'),
                subtitle: Text('March 5, 10:00 AM'),
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text('Vet Visit - Comet'),
                subtitle: Text('March 28, 11:30 AM'),
              ),
            ),

            const SizedBox(height: 20),

            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickActionButton(Icons.add, "Add Pet"),
                _quickActionButton(Icons.calendar_today, "Appointments"),
                _quickActionButton(Icons.fastfood, "Diet Plan"),
                _quickActionButton(Icons.pets, "Care Tips"),
              ],
            ),

            const SizedBox(height: 20),

            // Pet Care Tips
            const Text("Did You Know?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text("Dogs need at least 30 minutes of exercise daily for good health."),
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text("Just like us dogs also have different personalities and learning paces."),
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text("Cats use their long tails to balance themselves when they’re jumping or walking along narrow ledges."),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.brown,
        child: const Icon(Icons.pets, color: Colors.white70,),
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0x33A52A2A),
          child: Icon(icon, color: Colors.brown),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class PetCard extends StatelessWidget {
  final String name;
  final String imageUrl;

  const PetCard({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imageUrl),
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}