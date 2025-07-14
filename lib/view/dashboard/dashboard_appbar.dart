import 'package:flutter/material.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String nickname;
  final String date;
  final String? profilePicUrl;
  final VoidCallback onOpenDrawer;

  const DashboardAppBar({
    super.key,
    required this.nickname,
    required this.date,
    required this.profilePicUrl,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF8C5E35),
        ),
      ),
      toolbarHeight: 140,
      elevation: 0,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Hello, $nickname!",
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 3),
              Text(date,
                  style: const TextStyle(
                      fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: onOpenDrawer,
            child: CircleAvatar(
              radius: 25,
              backgroundImage: profilePicUrl != null
                  ? NetworkImage(profilePicUrl!)
                  : const AssetImage('assets/happy-family.png') as ImageProvider,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(140);
}
