class InventoryModel {
  final String id;
  final String namaBarang;
  final int stok;
  final String satuan; 

  InventoryModel({
    required this.id,
    required this.namaBarang,
    required this.stok,
    required this.satuan,
  });

  factory InventoryModel.fromFirestore(
      Map<String, dynamic> json, String docId) {
    return InventoryModel(
      id: docId,
      namaBarang: json['namaBarang'] ?? '',
      stok: (json['stok'] ?? 0).toInt(),
      satuan: json['satuan'] ?? 'Pcs',
    );
  }
}
