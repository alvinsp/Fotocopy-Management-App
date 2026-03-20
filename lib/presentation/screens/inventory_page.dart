import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_bloc.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_event.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_state.dart';
import 'package:fotocopy_app/logic/services/storage_sevice.dart';
import 'package:fotocopy_app/presentation/widgets/edit_stock_dialog.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String userRole = 'karyawan';

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  void _loadRole() async {
    final role = await StorageService.getUserRole();
    setState(() {
      userRole = role ?? 'karyawan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Stok")),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          if (state is InventoryLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                bool isLow = item.stok < 3;

                return Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (userRole != 'owner') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text("Hanya Owner yang boleh menghapus stok!")),
                      );
                      return false; // Batalkan hapus
                    }
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Hapus Barang?"),
                        content:
                            Text("Yakin ingin menghapus ${item.namaBarang}?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Batal")),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Hapus",
                                  style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    context
                        .read<InventoryBloc>()
                        .add(DeleteInventoryItem(item.id));

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${item.namaBarang} dihapus")),
                    );
                  },
                  child: Card(
                    color: isLow ? Colors.red[50] : Colors.white,
                    child: ListTile(
                      leading: Icon(Icons.inventory_2,
                          color: isLow ? Colors.red : Colors.indigo),
                      title: Text(item.namaBarang,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Sisa: ${item.stok} ${item.satuan}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => editStokDialog(context, item),
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
      // Tombol tambah barang baru ke Firebase (Opsional)
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddInventoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

void _showAddInventoryDialog(BuildContext context) {
  final namaController = TextEditingController();
  final stokController = TextEditingController();
  final satuanController =
      TextEditingController(text: "Rim"); // Default paling umum

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tambah Stok Barang Baru",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: namaController,
            decoration: const InputDecoration(
                labelText: "Nama Barang (Contoh: Kertas A4)",
                border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: stokController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: "Jumlah Awal", border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: satuanController,
                  decoration: const InputDecoration(
                      labelText: "Satuan",
                      hintText: "Rim/Pcs",
                      border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (namaController.text.isNotEmpty &&
                  stokController.text.isNotEmpty) {
                final int initialStok = int.tryParse(stokController.text) ?? 0;
                FirebaseFirestore.instance.collection('inventory').add({
                  'namaBarang': namaController.text,
                  'stok': initialStok,
                  'satuan': satuanController.text,
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text("Barang baru berhasil ditambahkan!")),
                );
              }
            },
            child: const Text("Simpan Barang",
                style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
