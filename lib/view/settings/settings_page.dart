//
import 'package:flutter/material.dart';
import 'package:bauwa/view/auth/login_screen.dart';
import 'package:bauwa/controllers/auth_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _nickname = "";
  String _email = "";
  String? _profilePicUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userData = await AuthController.instance.fetchUserData();
    if (userData != null) {
      setState(() {
        _nickname = userData['nickname'];
        _email = userData['email'];
        _profilePicUrl = userData['photoUrl'];
      });
    }
  }

  void _logout() async {
    await AuthController.instance.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9D1C7),
      body: Column(
        children: [
          /// Header with profile image and email
          Container(
            height: 250,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF8C5E35),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundImage: _profilePicUrl != null
                      ? NetworkImage(_profilePicUrl!)
                      : const AssetImage('assets/happy-family.png') as ImageProvider,
                ),
                const SizedBox(height: 10),
                Text(
                  _nickname,
                  style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          ///Settings options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),
                _sectionTitle("Account"),
                _settingTile(Icons.person, "Change Nickname", () {}),
                _settingTile(Icons.email, "Update Email", () {}),
                _settingTile(Icons.lock, "Change Password", () {}),
                _settingTile(Icons.logout, "Logout", () => _logout()),

                const SizedBox(height: 20),
                _sectionTitle("Preferences"),
                _switchTile(Icons.dark_mode, "Dark Mode", false, (value) {}),
                _switchTile(Icons.notifications, "Enable Notifications", true, (value) {}),

                const SizedBox(height: 20),
                _sectionTitle("Support"),
                _settingTile(Icons.contact_mail, "Contact Us", () {}),
                _settingTile(Icons.feedback, "Send Feedback", () {}),

                const SizedBox(height: 20),
                _sectionTitle("Legal"),
                _settingTile(Icons.policy, "Privacy Policy", () {}),
                _settingTile(Icons.article, "Terms of Service", () {}),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _settingTile(IconData icon, String title, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF8C5E35)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _switchTile(IconData icon, String title, bool value, Function(bool) onChanged) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        secondary: Icon(icon, color: Color(0xFF8C5E35)),
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: Color(0xFF169FAD),
      ),
    );
  }
}

