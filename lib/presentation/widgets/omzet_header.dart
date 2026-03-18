import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget omzetHeader(int total, DateTime date) {
  String formattedDate = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
    decoration: const BoxDecoration(
      color: Colors.indigo,
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
    ),
    child: Column(
      children: [
        Text(formattedDate,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 10),
        const Text("Omzet Selesai Hari Ini",
            style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 8),
        Text("Rp $total",
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
      ],
    ),
  );
}
