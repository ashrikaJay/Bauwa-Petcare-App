import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bauwa/view/pets/add_pets_page.dart';
import 'package:bauwa/view/pets/image_defaults.dart';

class PetsPage extends StatefulWidget {
  final VoidCallback? onOpenDrawer;
  const PetsPage({super.key, required this.onOpenDrawer});

  @override
  State<PetsPage> createState() => _PetsPageState();
}

class _PetsPageState extends State<PetsPage> {
  final CollectionReference petsCollection = FirebaseFirestore.instance.collection('pets');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Pets"),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: widget.onOpenDrawer ?? () {},
        ),
      ),

      backgroundColor: const Color(0xFFD9D1C7),
      body: StreamBuilder(
        stream: petsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching pets"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pets added yet."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.8,
            ),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var pet = snapshot.data!.docs[index];
              /*String imageUrl = (pet['image'] != null && pet['image'].toString().isNotEmpty)
                  ? pet['image']
                  : getDefaultImage(pet['breed']);*/

              String imageUrl = (pet['image'] != null && pet['image'].toString().isNotEmpty)
                  ? pet['image']
                  : getDefaultImage(pet['breed'], pet['color']);


              return GestureDetector(
                onTap: () {
                  // Navigate to pet details page
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                            image: DecorationImage(
                              image: imageUrl.startsWith('http')
                                  ? NetworkImage(imageUrl)  // Load user-uploaded image
                                  : AssetImage(imageUrl) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              pet['name'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text("Breed: ${pet['breed']}", style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetPage()),
          );
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white70,),
      ),
    );
  }
}


