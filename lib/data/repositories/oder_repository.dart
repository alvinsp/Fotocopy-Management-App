import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fotocopy_app/data/models/oder_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection('orders');

  Stream<List<OrderModel>> watchOrders() {
    return _orderCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addOrder(OrderModel order) async {
    await _orderCollection.add({
      'namaPelanggan': order.namaPelanggan,
      'totalHarga': order.totalHarga,
      'status': order.status,
      'kategori': order.kategori,
      'isLunas': order.isLunas,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> getOrders() {
    return _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await _orderCollection.doc(id).update({'status': status});
  }

  Future<void> deleteOrder(String id) async {
    await _orderCollection.doc(id).delete();
  }

  Stream<List<OrderModel>> watchOrdersByDate(DateTime date) {
    DateTime startOfDay = DateTime(date.year, date.month, date.day, 0, 0, 0);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _orderCollection
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThanOrEqualTo: endOfDay)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromFirestore(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}
