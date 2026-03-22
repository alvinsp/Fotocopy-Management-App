import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String namaPelanggan;
  final int totalHarga;
  final String status;
  final bool isLunas;
  final String kategori;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.namaPelanggan,
    required this.totalHarga,
    required this.status,
    required this.isLunas,
    required this.kategori,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderModel(
      id: id,
      namaPelanggan: data['namaPelanggan'] ?? '',
      totalHarga: (data['totalHarga'] ?? 0) as int,
      status: data['status'] ?? '',
      isLunas: data['isLunas'] ?? true,
      kategori: data['kategori'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
