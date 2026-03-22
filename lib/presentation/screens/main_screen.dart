import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_bloc.dart';
import 'package:fotocopy_app/logic/bloc/auth_bloc/auth_state.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/presentation/screens/dashboad_screen.dart';
import 'package:fotocopy_app/presentation/screens/history_page.dart';
import 'package:fotocopy_app/presentation/screens/inventory_page.dart';
import 'package:fotocopy_app/presentation/screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    const InventoryPage(),
    const HistoryPage(),
  ];

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
        body: _pages[_selectedIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.inventory_2_outlined),
              selectedIcon: Icon(Icons.inventory_2),
              label: 'Stok',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () => _showAddTransactionDialog(context),
                backgroundColor: Colors.indigo,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
      ),
    );
  }
}

void _showAddTransactionDialog(BuildContext context) {
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  String selectedKategori = 'Fotocopy';
  bool isLunas = true;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Input Pesanan Baru",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                      labelText: "Nama Pelanggan",
                      border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                items: ['Fotocopy', 'Print', 'Jilid', 'ATK']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  setModalState(() => selectedKategori = v!);
                },
                decoration: const InputDecoration(
                    labelText: "Kategori", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                  controller: hargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Total Harga",
                      prefixText: "Rp ",
                      border: OutlineInputBorder())),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: isLunas ? Colors.green[50] : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: isLunas ? Colors.green : Colors.orange),
                ),
                child: SwitchListTile(
                  title: Text(
                    isLunas ? "PEMBAYARAN LUNAS" : "BON (HUTANG)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isLunas ? Colors.green[700] : Colors.orange[800],
                    ),
                  ),
                  secondary: Icon(
                    isLunas ? Icons.check_circle : Icons.warning_amber_rounded,
                    color: isLunas ? Colors.green : Colors.orange,
                  ),
                  value: isLunas,
                  activeColor: Colors.green,
                  onChanged: (bool value) {
                    // 3. Sekarang setModalState akan bekerja dengan benar
                    setModalState(() {
                      isLunas = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  if (namaController.text.isNotEmpty &&
                      hargaController.text.isNotEmpty) {
                    final nama = namaController.text;
                    final harga = int.tryParse(hargaController.text) ?? 0;
                    final kategori = selectedKategori;

                    context.read<TransactionBloc>().add(AddOrderRequested(
                          nama,
                          harga,
                          kategori,
                          isLunas, // Data terkirim sesuai switch!
                        ));

                    Navigator.of(context).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor:
                            isLunas ? Colors.green : Colors.orange[800],
                        content: Text(isLunas
                            ? "Pesanan Lunas dicatat!"
                            : "Pesanan BON dicatat!"),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: const Text("Simpan Pesanan",
                    style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    ),
  );
}
