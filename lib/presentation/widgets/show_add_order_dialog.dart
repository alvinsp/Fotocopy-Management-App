import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fotocopy_app/logic/bloc/transaction_bloc/transaction_event.dart';

void showAddOrderDialog(BuildContext context) {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  String selectedKategori = 'Fotocopy';

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nama Pelanggan")),
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
              decoration: const InputDecoration(labelText: "Kategori Layanan"),
              items: listKategori.map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) {
                setState(() => selectedKategori = newValue!);
              },
            ),
          ],
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
                      AddOrderRequested(name, price, selectedKategori),
                    );
                Navigator.pop(context);
              },
              child: const Text("Simpan")),
        ],
      ),
    ),
  );
}
