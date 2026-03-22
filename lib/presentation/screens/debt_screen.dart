import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_state.dart';

class DebtListScreen extends StatelessWidget {
  const DebtListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Piutang (Bon)")),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoaded) {
            // Filter hanya yang BELUM LUNAS
            final debtList = state.orders.where((o) => !o.isLunas).toList();

            if (debtList.isEmpty) {
              return const Center(child: Text("Alhamdulillah, semua lunas!"));
            }

            return ListView.builder(
              itemCount: debtList.length,
              itemBuilder: (context, index) {
                final item = debtList[index];
                return ListTile(
                  title: Text(item.namaPelanggan),
                  subtitle: Text("Total: Rp ${item.totalHarga}"),
                  trailing: ElevatedButton(
                    onPressed: () {
                      context
                          .read<TransactionBloc>()
                          .add(MarkAsPaidRequested(item.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${item.namaPelanggan} Lunas!")),
                      );
                    },
                    child: const Text("Tandai Lunas"),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
