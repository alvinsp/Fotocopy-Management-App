class UserModel {
  final String uid;
  final String email;
  final String role; 

  UserModel({required this.uid, required this.email, required this.role});

  factory UserModel.fromFirestore(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      email: json['email'] ?? '',
      role: json['role'] ?? 'karyawan', 
    );
  }
}
