class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String role;

  UserModel(
      {required this.uid,
      required this.nama,
      required this.email,
      required this.role});

  factory UserModel.fromFirestore(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      nama: json['nama'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'karyawan',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'email': email,
      'role': role,
    };
  }
}
