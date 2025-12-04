class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phone;
  final String role;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
    };
  }

  bool get isSuperAdmin => role == 'superadmin';
  bool get isAdminKUA => role == 'admin_kua';
  bool get isAdminDukcapil => role == 'admin_dukcapil';
  bool get isUser => role == 'user';
  bool get isAdmin => isSuperAdmin || isAdminKUA || isAdminDukcapil;
}
