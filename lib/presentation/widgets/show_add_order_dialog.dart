import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';

void showAddOrderDialog(BuildContext context) {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  String selectedKategori = 'Fotocopy';
  bool isLunas = true;

  final List<String> listKategori = [
    'Fotocopy',
    'Print',
    'Jilid',
    'ATK',
    'Lainnya'
  ];

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text("Tambah Antrean"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Nama Pelanggan")),
                const SizedBox(height: 8),
                TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: "Harga (Rp)"),
                    keyboardType: TextInputType.number),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<String>(
                  value: selectedKategori,
                  decoration:
                      const InputDecoration(labelText: "Kategori Layanan"),
                  items: listKategori.map((String value) {
                    return DropdownMenuItem<String>(
                        value: value, child: Text(value));
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => selectedKategori = newValue!);
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isLunas ? Colors.green[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isLunas ? Colors.green : Colors.orange),
                  ),
                  child: SwitchListTile(
                    title: Text(
                      isLunas ? "LUNAS (Cash)" : "BON (Hutang)",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isLunas ? Colors.green[700] : Colors.orange[800],
                      ),
                    ),
                    value: isLunas,
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        isLunas = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Batal")),
          ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final priceText = priceController.text.trim();
                final price = int.tryParse(priceText);

                if (name.isEmpty || price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content:
                          Text("Input tidak valid! Periksa Nama & Harga.")));
                  return;
                }

                context.read<TransactionBloc>().add(
                      AddOrderRequested(name, price, selectedKategori, isLunas),
                    );

                isLunas = true;
                Navigator.pop(context);
              },
              child: const Text("Simpan")),
        ],
      ),
    ),
  );
}
