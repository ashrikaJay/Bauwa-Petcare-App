import 'package:flutter/material.dart';
/*
class QuickActionsRow extends StatelessWidget {
  final VoidCallback onAddPet;
  final VoidCallback onAppointments;
  final VoidCallback onDietPlan;
  final VoidCallback onCareTips;

  const QuickActionsRow({
    super.key,
    required this.onAddPet,
    required this.onAppointments,
    required this.onDietPlan,
    required this.onCareTips,
  });

  Widget _quickActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: const Color(0x33A52A2A),
            child: Icon(icon, color: Colors.brown),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _quickActionButton(Icons.add, "Add Pet", onAddPet),
        _quickActionButton(Icons.calendar_today, "Appointments", onAppointments),
        _quickActionButton(Icons.fastfood, "Diet Plan", onDietPlan),
        _quickActionButton(Icons.pets, "Care Tips", onCareTips),
      ],
    );
  }
}*/