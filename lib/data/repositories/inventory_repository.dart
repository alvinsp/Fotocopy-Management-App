import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fotocopy_app/data/models/inventory_model.dart';

class InventoryRepository {
  final _inventoryCollection =
      FirebaseFirestore.instance.collection('inventory');

  Stream<List<InventoryModel>> watchInventory() {
    return _inventoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return InventoryModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateStok(String id, int jumlahBaru) async {
    await _inventoryCollection.doc(id).update({'stok': jumlahBaru});
  }
}
