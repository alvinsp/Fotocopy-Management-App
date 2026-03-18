import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_event.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_state.dart';
import 'package:fotocopy_app/presentation/widgets/omzet_header.dart';
import 'package:fotocopy_app/presentation/widgets/order_card.dart';
import 'package:fotocopy_app/presentation/widgets/row_kategori.dart';
import 'package:fotocopy_app/presentation/widgets/show_add_order_dialog.dart';
import 'package:fotocopy_app/presentation/widgets/summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Fotocopy Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                context
                    .read<TransactionBloc>()
                    .add(ChangeDateRequested(pickedDate));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthBloc>().add(LogoutRequested()),
          )
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final listSelesai =
                state.orders.where((o) => o.status == 'selesai').toList();
            final listAntrean =
                state.orders.where((o) => o.status == 'menunggu').toList();

            final omzet =
                listSelesai.fold(0, (sum, item) => sum + item.totalHarga);

            int hitungPerKategori(String namaKat) {
              return listSelesai
                  .where((o) => o.kategori == namaKat)
                  .fold(0, (sum, item) => sum + item.totalHarga);
            }

            int omzetFotocopy = hitungPerKategori('Fotocopy');
            int omzetPrint = hitungPerKategori('Print');
            int omzetJilid = hitungPerKategori('Jilid');
            int omzetATK = hitungPerKategori('ATK');

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OmzetHeader(total: omzet, date: state.selectedDate),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10)
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Rincian Pendapatan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const Divider(height: 20),
                          rowKategori("Fotocopy", omzetFotocopy, Colors.orange),
                          rowKategori("Print", omzetPrint, Colors.blue),
                          rowKategori("Jilid", omzetJilid, Colors.green),
                          rowKategori("ATK", omzetATK, Colors.purple),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Statistik Hari Ini",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.6,
                          children: [
                            summaryCard("Antrean", "${listAntrean.length}",
                                Icons.hourglass_empty, Colors.orange),
                            summaryCard("Selesai", "${listSelesai.length}",
                                Icons.check_circle_outline, Colors.green),
                            summaryCard("Kertas A4", "2 Rim", Icons.description,
                                Colors.blue),
                            summaryCard("Toner", "85%", Icons.format_color_fill,
                                Colors.purple),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Cari nama pelanggan...",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              context
                                  .read<TransactionBloc>()
                                  .add(SearchNameRequested(value));
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text("Antrean Print Terbaru",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.orders.length,
                          itemBuilder: (context, index) {
                            final order = state.orders[index];
                            return orderCard(context, order);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(
              child: Text("Gagal memuat data atau data kosong"));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddOrderDialog(context),
        label: const Text("Antrean Baru"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    );
  }
}
