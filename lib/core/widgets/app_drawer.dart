import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String nickname;
  final String email;
  final String? profilePicUrl;
  final VoidCallback onNavigateToSettings;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.nickname,
    required this.email,
    required this.profilePicUrl,
    required this.onNavigateToSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Color(0xFFD9D1C7),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(nickname, style: const TextStyle(fontSize: 18)),
              accountEmail: Text(email, style: const TextStyle(fontSize: 14)),
              currentAccountPicture: CircleAvatar(
                radius: 40,
                backgroundImage: profilePicUrl != null
                    ? NetworkImage(profilePicUrl!)
                    : const AssetImage('assets/dogs/dachshund.png.png')
                        as ImageProvider,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF8C5E35), // Background color of drawer header
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.black),
              title: const Text('My Profile'),
              onTap: () {
                //Navigate to My Profile Screen
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.black),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context); // close drawer
                onNavigateToSettings(); // switch tab to Settings
              },

            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip, color: Colors.black),
              title: const Text('Privacy Terms & Conditions'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_box, color: Colors.black),
              title: const Text('Manage Account'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.black),
              title: const Text("Logout", style: TextStyle(fontSize: 16)),
              onTap: onLogout, // Calls the logout function
            ),
          ],
        ),
      ),
    );
  }
}
