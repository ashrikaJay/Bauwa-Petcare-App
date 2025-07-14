import 'package:flutter/material.dart';

class PetProfile extends StatelessWidget {
  final String name;
  final String imageUrl;

  const PetProfile({super.key, required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.brown, width: 3),
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

/*class PetCard extends StatelessWidget {
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
}*/

}
