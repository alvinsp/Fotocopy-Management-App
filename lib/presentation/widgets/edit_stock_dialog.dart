import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fotocopy_app/data/models/inventory_model.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_bloc.dart';
import 'package:fotocopy_app/logic/bloc/inventory_bloc/inventory_event.dart';

void editStokDialog(BuildContext context, InventoryModel item) {
  final stokController = TextEditingController(text: item.stok.toString());

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text("Update Stok: ${item.namaBarang}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Satuan: ${item.satuan}",
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: stokController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Jumlah Stok Baru",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.edit),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text("Batal"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
          onPressed: () {
            final newStok = int.tryParse(stokController.text);
            if (newStok != null && newStok >= 0) {
              context
                  .read<InventoryBloc>()
                  .add(UpdateStokRequested(item.id, newStok));
              Navigator.pop(context);
              if (newStok < 3) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                        "⚠️ Stok ${item.namaBarang} kritis! Segera belanja."),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Stok berhasil diperbarui")),
                );
              }
            }
          },
          child: const Text("Simpan", style: TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
