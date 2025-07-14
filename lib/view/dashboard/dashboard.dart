import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bauwa/core/widgets/pet_circular_profile.dart';
import 'package:bauwa/view/pets/add_pets_page.dart';
import 'package:bauwa/view/pets/pets_page.dart';
import 'package:bauwa/view/pets/image_defaults.dart';
import 'package:bauwa/view/dashboard/dashboard_widgets.dart';
import 'package:bauwa/view/dashboard/dashboard_appbar.dart';
import 'package:bauwa/view/dashboard/dashboard_actions.dart';
import 'package:bauwa/controllers/auth_controller.dart';

class DashboardPage extends StatefulWidget {
  final VoidCallback onOpenDrawer;
  const DashboardPage({super.key, required this.onOpenDrawer});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _nickname = "";
  String _currentDate = "";
  String? _profilePicUrl;
  //String _email = ""; //for future


  @override
  void initState() {
    super.initState();
    /// Fetch nickname,email and profile picture from Firebase (Hello Ashi)
    AuthController.instance.fetchUserData().then((userData) {
      if (userData != null) {
        setState(() {
          _nickname = userData['nickname'] ?? '';
          _profilePicUrl = userData['photoUrl'];
          //_email = userData['email']; // for future
        });
      }
    });
    _updateDate();
  }

  /// Update current date dynamically
  void _updateDate() {
    setState(() {
      _currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
    });
  }

  /// Fetch pets from Firestore
  Stream<QuerySnapshot> _fetchPets() {
    return _firestore.collection('pets').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //key: _scaffoldKey,

      /// Dashboard App Bar
      appBar: DashboardAppBar(
        nickname: _nickname,
        date: _currentDate,
        profilePicUrl: _profilePicUrl,
        onOpenDrawer: widget.onOpenDrawer,
      ),

      //backgroundColor: Color(0xFF4FB1A1),
      //backgroundColor: Color(0xFFA7AD89),
      backgroundColor: Color(0xFFD9D1C7),

      /// Body Content
      body: SingleChildScrollView(
        child: Column(
          children: [
            // This container creates a nice curved "card" look for content
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D1C7), // or any background color
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  /// Pet Profiles Section
                  const Text('Your Pets',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                                String imageUrl = (pet['image'] != null &&
                                        pet['image'].toString().isNotEmpty)
                                    ? pet['image']
                                    : getDefaultImage(
                                        pet['breed'], pet['color']);

                                return PetProfile(
                                    name: pet['name'], imageUrl: imageUrl);
                              },
                            ),
                          ),

                          ///View More Option
                          if (showViewMore)
                            Padding(
                              padding: const EdgeInsets.only(top: 0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              PetsPage(
                                                onOpenDrawer: () {},
                                              ),
                                      ),
                                    );
                                  },
                                  child: const Text("View More",
                                      style: TextStyle(
                                          color: Colors.brown, fontSize: 16)),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  buildDashboardCard(),
                  const SizedBox(height: 10),

                  /// Quick Actions Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      QuickAction(
                        icon: Icons.add,
                        label: "Add Pet",
                            onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddPetPage()),
                          );
                        },
                      ),
                      QuickAction(
                        icon: Icons.calendar_today,
                        label: "Appointments",
                            onTap: () {},
                      ),
                      QuickAction(
                        icon: Icons.fastfood,
                        label: "Diet Plan",
                            onTap: () {},
                      ),
                      QuickAction(
                        icon: Icons.pets,
                        label: "Care Tips",
                            onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// Upcoming Appointments Section
                  const Text('Upcoming Appointments',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  appointmentCard('Vet Visit - Angelina', 'March 5, 10:00 AM'),
                  const SizedBox(height: 10),
                  appointmentCard('Vet Visit - Comet', 'March 28, 11:30 AM'),

                  const SizedBox(height: 20),

                  /// Pet Care Tips
                  const Text("Did You Know?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  tipCard(
                      "Dogs need at least 30 minutes of exercise daily for good health."),
                  tipCard(
                      "Just like us dogs also have different personalities and learning paces."),
                  tipCard(
                      "Cats use their long tails to balance themselves when they’re jumping or walking along narrow ledges."),
                ],
              ),
            ),
          ],
        ),
      ),

      ///Floating Action Button: take this down if not needed
      /*floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.brown,
        child: const Icon(Icons.pets, color: Colors.white70,),
      ),*/
    );
  }
}
/// main class