import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
        elevation: 3,
      ),
      child: Image.asset(
        'assets/icons/google-icon.png',
        height: 40,
        width: 40,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.account_circle, size: 40, color: Colors.blue);
        },
      ),
    );
  }
}
