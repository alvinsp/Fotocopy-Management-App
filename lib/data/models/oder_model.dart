import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String namaPelanggan;
  final int totalHarga;
  final String status;
  final String kategori;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.namaPelanggan,
    required this.totalHarga,
    required this.status,
    required this.kategori,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(
      Map<String, dynamic> json, String documentId) {
    return OrderModel(
      id: documentId,
      namaPelanggan: json['namaPelanggan'] ?? '',
      totalHarga: (json['totalHarga'] ?? 0).toInt(),
      status: json['status'] ?? 'menunggu',
      kategori: json['kategori'] ?? 'Fotocopy',
      createdAt: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
