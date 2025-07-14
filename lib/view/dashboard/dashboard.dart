import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:bauwa/view/auth/login_screen.dart';
import 'package:bauwa/core/widgets/app_drawer.dart';
import 'package:bauwa/pets/addpets.dart';
import 'package:bauwa/pets/pets.dart';
import 'package:bauwa/pets/image-defaults.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _nickname = ""; // Default placeholder
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

      // Fetch nickname from Firestore if available
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

  // Fetch pets from Firestore
  Stream<QuerySnapshot> _fetchPets() {
    return _firestore.collection('pets').snapshots();
  }

  // Logout function
  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      /// undone from here start -app bar version 1
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes default back button
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.brown, // Darker at the top
                Color(0xFFD2B48C), // Lighter brown towards bottom (Tan)
              ],
            ),
          ),
        ),
        toolbarHeight: 140, // Increased height to give space for the greeting section
        elevation: 0, // Removes default shadow
        title: Align(
          alignment: Alignment.centerLeft, // Aligns text to the left
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 20.0), // Adjust padding for positioning
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Ensures both texts are aligned left
              mainAxisSize: MainAxisSize.min, // Prevents unnecessary spacing
              children: [
                Text(
                  "Hello, $_nickname!",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 3), // Slight spacing between nickname and date
                Text(
                  _currentDate,
                  style: const TextStyle(fontSize: 14, color: Colors.white70), // Reduced font size
                ),
              ],
            ),
          ),
        ),

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: CircleAvatar(
                radius: 25,
                backgroundImage: _profilePicUrl != null
                    ? NetworkImage(_profilePicUrl!)
                    : const AssetImage('assets/happy-family.png'),
              ),
            ),
          ),
        ],
      ),

      /// undone from here end -app bar version 1

      drawer: CustomDrawer(
        nickname: _nickname,
        email: _email,
        profilePicUrl: _profilePicUrl,
        onLogout: _logout,
      ),


      /// without appbar taken down start
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDashboardCard(),
            // Pet Profiles Section
            const Text('Your Pets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 15),

            StreamBuilder<QuerySnapshot>(
              stream: _fetchPets(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text("Error fetching pets"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No pets added yet."));
                }

                var pets = snapshot.data!.docs;
                bool showViewMore = pets.length > 4;

                return Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: showViewMore ? 4 : pets.length,
                        itemBuilder: (context, index) {
                          var pet = pets[index];
                          String imageUrl = (pet['image'] != null && pet['image'].toString().isNotEmpty)
                              ? pet['image']
                              : getDefaultImage(pet['breed'], pet['color']);

                          return PetCard(name: pet['name'], imageUrl: imageUrl);
                        },
                      ),
                    ),

                    if (showViewMore)
                      Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const PetsPage()),
                              );
                            },
                            child: const Text("View More", style: TextStyle(color: Colors.brown, fontSize: 16)),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            //const SizedBox(height: 5),

            // Upcoming Appointments Section
            const Text('Upcoming Appointments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
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
                _quickActionButton(
                  Icons.add,
                  "Add Pet",
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddPetPage()),
                    );
                  },
                ),
                _quickActionButton(
                  Icons.calendar_today,
                  "Appointments",
                      () {

                  },
                ),
                _quickActionButton(
                  Icons.fastfood,
                  "Diet Plan",
                      () {
                  },
                ),
                _quickActionButton(
                  Icons.pets,
                  "Care Tips",
                      () {

                  },
                ),
              ],
            ),

            const SizedBox(height: 20),
            // Pet Care Tips
            const Text("Did You Know?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _tipCard("Dogs need at least 30 minutes of exercise daily for good health."),
            _tipCard("Just like us dogs also have different personalities and learning paces."),
            _tipCard("Cats use their long tails to balance themselves when they’re jumping or walking along narrow ledges."),
          ],
        ),
        /// remove this end

      ),



      /// without appbar taken down end
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.brown,
        child: const Icon(Icons.pets, color: Colors.white70,),
      ),
    );
  }
} /// main class

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
          /*CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imageUrl),
          ),*/
          Container(
            //padding: const EdgeInsets.all(3), // Space for the border
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 3), // Brown Border
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: imageUrl.startsWith('http')
                  ? NetworkImage(imageUrl)
                  : AssetImage(imageUrl) as ImageProvider,
            ),
          ),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(
          radius: 25,//0x33A52A2A
          backgroundColor: Color(0xAD79E8E5),
          child: Icon(icon, color: Colors.brown),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}

//UI widgets_test
Widget _buildDashboardCard() {
  return Container(
    margin: const EdgeInsets.only(top: 10, bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Today’s Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("2 appointments • 4 pets", style: TextStyle(color: Colors.grey)),
          ],
        ),
        const Icon(Icons.insights, color: Colors.brown),
      ],
    ),
  );
}

Widget _tipCard(String tip) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: Color(0xFFCBB293),
    child: ListTile(
      leading: const Icon(Icons.mood, color: Colors.brown),
      title: Text(tip),
    ),
  );
}