import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'client',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: (map['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }
}
