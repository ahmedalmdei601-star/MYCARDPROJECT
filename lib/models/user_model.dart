class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'client',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'role': role,
    };
  }
}
