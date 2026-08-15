import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  employee,
  agent,
  manager;

  String get displayName {
    switch (this) {
      case UserRole.employee:
        return 'Employee';
      case UserRole.agent:
        return 'Support Agent';
      case UserRole.manager:
        return 'Manager';
    }
  }

  static UserRole fromString(String? value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value?.toLowerCase(),
      orElse: () => UserRole.employee,
    );
  }
}

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String department;
  final String? avatarUrl;
  final bool isVerified;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = UserRole.employee,
    this.department = 'General',
    this.avatarUrl,
    this.isVerified = false,
    required this.createdAt,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? department,
    String? avatarUrl,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'department': department,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    final role = UserRole.fromString(map['role']);
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: role,
      department: map['department'] ?? 'General',
      avatarUrl: map['avatarUrl'],
      isVerified: map['isVerified'] ?? (role == UserRole.manager),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
