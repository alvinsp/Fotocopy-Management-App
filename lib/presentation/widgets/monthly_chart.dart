import 'package:flutter/material.dart';
import 'package:fotocopy_app/data/models/oder_model.dart';
import 'package:intl/intl.dart';

class MonthlyChart extends StatelessWidget {
  final List<OrderModel> orders;
  const MonthlyChart({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    Map<String, double> dailyData = {};
    for (int i = 6; i >= 0; i--) {
      DateTime day = DateTime.now().subtract(Duration(days: i));
      dailyData[DateFormat('E', 'id_ID').format(day)] = 0.0;
    }

    for (var order in orders) {
      if (order.status == 'selesai') {
        String dayName = DateFormat('E', 'id_ID').format(order.createdAt);
        if (dailyData.containsKey(dayName)) {
          dailyData[dayName] = dailyData[dayName]! + order.totalHarga;
        }
      }
    }

    double maxVal = dailyData.values.fold(0, (prev, e) => e > prev ? e : prev);
    if (maxVal == 0) maxVal = 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Grafik Pendapatan 7 Hari",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: dailyData.entries.map((entry) {
              double barHeight = (entry.value / maxVal) * 100;
              return Column(
                children: [
                  Container(
                    width: 25,
                    height: barHeight + 5,
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(entry.key, style: const TextStyle(fontSize: 10)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
