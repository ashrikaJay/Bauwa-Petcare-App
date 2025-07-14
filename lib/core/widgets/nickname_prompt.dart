import 'package:flutter/material.dart';

class NicknamePrompt extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSave;

  const NicknamePrompt({
    super.key,
    required this.controller,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter Your Nickname"),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: "Enter nickname"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // cancel
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: onSave,
          child: const Text("Save"),
        ),
      ],
    );
  }
}
