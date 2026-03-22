import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_state.dart';
import 'package:fotocopy_app/presentation/widgets/order_card.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Arsip Transaksi")),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoaded) {
            final finishedOrders =
                state.orders.where((o) => o.status == 'selesai').toList();

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finishedOrders.length,
              itemBuilder: (context, index) {
                final order = finishedOrders[index];
                return orderCard(context, order);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
