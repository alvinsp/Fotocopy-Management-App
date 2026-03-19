import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';
import 'package:fotocopy_app/presentation/screens/dashboad_screen.dart';
import 'package:fotocopy_app/presentation/screens/history_page.dart';
import 'package:fotocopy_app/presentation/screens/inventory_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman kita
  final List<Widget> _pages = [
    const DashboardScreen(), // Isi kodingan dashboard kamu yang sekarang
    const InventoryPage(), // Halaman stok khusus
    const HistoryPage(), // Halaman arsip transaksi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}

void _showAddTransactionDialog(BuildContext context) {
  final namaController = TextEditingController();
  final hargaController = TextEditingController();
  String selectedKategori = 'Fotocopy'; // Default

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (context) => Padding(
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
                  labelText: "Nama Pelanggan", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedKategori,
            items: ['Fotocopy', 'Print', 'Jilid', 'ATK']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => selectedKategori = v!,
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
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                minimumSize: const Size(double.infinity, 50)),
            onPressed: () {
              if (namaController.text.isNotEmpty &&
                  hargaController.text.isNotEmpty) {
                // KIRIM KE TRANSACTION BLOC
                context.read<TransactionBloc>().add(AddOrderRequested(
                      namaController.text,
                      int.parse(hargaController.text),
                      selectedKategori,
                    ));
                Navigator.pop(context);
              }
            },
            child: const Text("Simpan Pesanan",
                style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
