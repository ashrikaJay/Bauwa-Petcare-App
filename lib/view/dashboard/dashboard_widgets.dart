import 'package:flutter/material.dart';

/*///Quick Action Styling
Widget quickActionButton(IconData icon, String label, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: const Color(0xFF632024),
          child: Icon(icon, color: Color(0xFFD9D1C7)),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    ),
  );
}*/

///Analytics Card for pets
Widget buildDashboardCard() {
  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFAD9274),
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
            Text("Today’s Overview",
                style: TextStyle(
                    color: Color(0xFF632024),
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("2 appointments • 4 pets", style: TextStyle(color: Colors.white)),
          ],
        ),
        const Icon(Icons.insights, color: Color(0xFF632024)),
      ],
    ),
  );
}

///Pet Care Tips
Widget tipCard(String tip) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: const Color(0xFFCBB293),
    child: ListTile(
      leading: const Icon(Icons.mood, color: Colors.brown),
      title: Text(tip),
    ),
  );
}

///Demo Appointment Card
Widget appointmentCard(String title, String subtitle) {
  return Card(
    color: Color(0xFF169FAD),
    child: ListTile(
      leading: Icon(Icons.calendar_today, color: Color(0xFF632024)),
      title: Text(title,
          style: TextStyle(color: Color(0xFF632024), fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Color(0xFFD9D1C7), fontWeight: FontWeight.w500)),
    ),
  );
}

