import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/data/models/oder_model.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';

Widget orderCard(BuildContext context, OrderModel order) {
  bool isSelesai = order.status == 'selesai';

  return Dismissible(
    key: Key(order.id),
    direction: DismissDirection.endToStart, // Geser ke kiri saja
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (direction) {
      context.read<TransactionBloc>().add(DeleteOrderRequested(order.id));
    },
    child: Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isSelesai ? Colors.green[50] : Colors.orange[50],
          child: Icon(
            isSelesai ? Icons.check : Icons.access_time,
            color: isSelesai ? Colors.green : Colors.orange,
          ),
        ),
        title: Text(order.namaPelanggan,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Rp ${order.totalHarga}"),
        trailing: isSelesai
            ? const Icon(Icons.done_all, color: Colors.blue)
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  context
                      .read<TransactionBloc>()
                      .add(UpdateStatus(order.id, 'selesai'));
                },
                child: const Text("Selesai"),
              ),
      ),
    ),
  );
}
