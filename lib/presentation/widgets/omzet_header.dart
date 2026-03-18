import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OmzetHeader extends StatelessWidget {
  final int total;
  final DateTime date;

  const OmzetHeader({super.key, required this.total, required this.date});

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);

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
          const SizedBox(height: 8),
          const Text("Total Omzet Selesai",
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          Text("Rp $total",
              style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}
