import 'dart:convert';

class User {
  final String userId;
  final String phone;
  final String role;
  final String name;
  final List<String> canHaveRoles;

  const User({
    required this.userId,
    required this.phone,
    required this.role,
    required this.name,
    required this.canHaveRoles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    json = json['result'];
    return User(
      userId: json['_id'],
      name: json['name'],
      phone: json['phone'],
      role: json['role'],
      canHaveRoles: List<String>.from(json['canHaveRoles']),
    );
  }
}
