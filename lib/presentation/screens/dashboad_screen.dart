import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fotocopy_app/core/string_extension.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_event.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_state.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_bloc.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_event.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_state.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_state.dart';
import 'package:fotocopy_app/logic/services/pdf_service.dart';
import 'package:fotocopy_app/logic/services/storage_sevice.dart';
import 'package:fotocopy_app/presentation/screens/debt_screen.dart';
import 'package:fotocopy_app/presentation/screens/login_screen.dart';
import 'package:fotocopy_app/presentation/widgets/edit_stock_dialog.dart';
import 'package:fotocopy_app/presentation/widgets/monthly_chart.dart';
import 'package:fotocopy_app/presentation/widgets/omzet_header.dart';
import 'package:fotocopy_app/presentation/widgets/order_card.dart';
import 'package:fotocopy_app/presentation/widgets/row_kategori.dart';
import 'package:fotocopy_app/presentation/widgets/summary_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userRole = 'karyawan';
  final String? nomorOwner = dotenv.env['NOMOR_WA'];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  void _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('user_role') ?? 'karyawan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
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
              onPressed: () async {
                context.read<TransactionBloc>().add(ClearTransactionData());
                context.read<InventoryBloc>().add(ClearInventoryData());

                await StorageService.clearAll();

                await Future.delayed(const Duration(milliseconds: 100));

                context.read<AuthBloc>().add(LogoutRequested());
              },
            )
          ],
        ),
        body: BlocBuilder<TransactionBloc, TransactionState>(
          builder: (context, state) {
            if (state is TransactionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TransactionLoaded) {
              final totalPiutang = state.orders
                  .where((o) => !o.isLunas)
                  .fold(0, (sum, item) => sum + item.totalHarga);
              final jumlahOrang = state.orders.where((o) => !o.isLunas).length;
              final listHariIni = state.orders.where((o) {
                return o.createdAt.year == state.selectedDate.year &&
                    o.createdAt.month == state.selectedDate.month &&
                    o.createdAt.day == state.selectedDate.day;
              }).toList();
              final listSelesaiHariIni =
                  listHariIni.where((o) => o.status == 'selesai').toList();

              final listAntrean =
                  state.orders.where((o) => o.status == 'menunggu').toList();

              final omzet = listSelesaiHariIni.fold(
                  0, (sum, item) => sum + item.totalHarga);

              int hitungPerKategori(String namaKat) {
                return listSelesaiHariIni
                    .where((o) => o.kategori == namaKat)
                    .fold(0, (sum, item) => sum + item.totalHarga);
              }

              int omzetFotocopy = hitungPerKategori('Fotocopy');
              int omzetPrint = hitungPerKategori('Print');
              int omzetJilid = hitungPerKategori('Jilid');
              int omzetATK = hitungPerKategori('ATK');

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userRole == 'owner')
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
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              const Divider(height: 20),
                              rowKategori("Fotocopy", omzetFotocopy.toIDR(),
                                  Colors.orange),
                              rowKategori(
                                  "Print", omzetPrint.toIDR(), Colors.blue),
                              rowKategori(
                                  "Jilid", omzetJilid.toIDR(), Colors.green),
                              rowKategori(
                                  "ATK", omzetATK.toIDR(), Colors.purple),
                              if (userRole == 'owner') ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Duit Masuk (Cash):"),
                                    Text(omzet.toIDR(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Piutang (Belum Bayar):"),
                                    Text(
                                      listHariIni
                                          .where((o) => !o.isLunas)
                                          .fold(
                                              0,
                                              (sum, item) =>
                                                  sum + item.totalHarga)
                                          .toIDR(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Sedang menyiapkan PDF..."),
                                            duration: Duration(seconds: 1)));
                                    try {
                                      await PdfService.generateReport(
                                          listSelesaiHariIni,
                                          state.selectedDate,
                                          omzet);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text("Gagal cetak PDF: $e")));
                                    }
                                  },
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text("Cetak Laporan PDF"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                        const Size(double.infinity, 45),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed: () async {
                                    final String tanggal =
                                        "${state.selectedDate.day}-${state.selectedDate.month}-${state.selectedDate.year}";
                                    final String pesan =
                                        "*LAPORAN HARIAN ABHECE FOTOCOPY*\n"
                                        "Tanggal: $tanggal\n"
                                        "--------------------------------\n"
                                        "✅ Omzet Lunas: ${omzet.toIDR()}\n"
                                        "⚠️ Piutang (Bon): ${listHariIni.where((o) => !o.isLunas).fold(0, (sum, item) => sum + item.totalHarga).toIDR()}\n"
                                        "--------------------------------\n"
                                        "Total Transaksi: ${listHariIni.length}\n"
                                        "Tetap semangat, Bos! 🚀";

                                    final url =
                                        "https://wa.me/$nomorOwner?text=${Uri.encodeComponent(pesan)}";

                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    }
                                  },
                                  icon: const Icon(Icons.send_rounded),
                                  label:
                                      const Text("Kirim Laporan ke WhatsApp"),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green[800],
                                    side: BorderSide(color: Colors.green[800]!),
                                    minimumSize:
                                        const Size(double.infinity, 45),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              ]
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Status Transaksi",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.8,
                            children: [
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DebtListScreen())),
                                child: summaryCard(
                                  "Total BON",
                                  totalPiutang.toIDR(),
                                  Icons.money_off,
                                  Colors.red[700]!,
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DebtListScreen())),
                                child: summaryCard(
                                    "Belum Bayar",
                                    "$jumlahOrang Orang",
                                    Icons.people_outline,
                                    Colors.orange[900]!),
                              ),
                              summaryCard("Antrean", "${listAntrean.length}",
                                  Icons.hourglass_empty, Colors.orange),
                              summaryCard(
                                  "Selesai",
                                  "${listSelesaiHariIni.length}",
                                  Icons.check_circle_outline,
                                  Colors.green),
                            ],
                          ),
                          const SizedBox(height: 24),
                          const Text("Stok Inventori",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          BlocBuilder<InventoryBloc, InventoryState>(
                            builder: (context, invState) {
                              if (invState is InventoryLoaded) {
                                final lowStockItems = invState.items
                                    .where((item) => item.stok < 3)
                                    .toList();

                                return Column(
                                  children: [
                                    if (lowStockItems.isNotEmpty)
                                      _buildWarningStock(lowStockItems),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 1.8,
                                      ),
                                      itemCount: invState.items.length,
                                      itemBuilder: (context, index) {
                                        final item = invState.items[index];
                                        return InkWell(
                                          onTap: () =>
                                              editStokDialog(context, item),
                                          child: summaryCard(
                                            item.namaBarang,
                                            "${item.stok} ${item.satuan}",
                                            Icons.inventory_2_outlined,
                                            item.stok < 3
                                                ? Colors.red
                                                : Colors.blue,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                          const SizedBox(height: 24),
                          const Text("Tren Pendapatan (7 Hari)",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          MonthlyChart(orders: state.orders),
                          const SizedBox(height: 24),
                          _buildSearchField(context),
                          const SizedBox(height: 24),
                          const Text("Antrean Print Terbaru",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: listHariIni.length,
                            itemBuilder: (context, index) =>
                                orderCard(context, listHariIni[index]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text("Menyinkronkan data..."),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  TextField _buildSearchField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Cari nama pelanggan...",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
      onChanged: (value) =>
          context.read<TransactionBloc>().add(SearchNameRequested(value)),
    );
  }
}

Widget _buildWarningStock(List lowStockItems) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red[200]!),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: Colors.red),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            "Peringatan: Stok ${lowStockItems.map((e) => e.namaBarang).join(', ')} hampir habis!",
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}
