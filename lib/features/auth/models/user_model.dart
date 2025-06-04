import 'dart:convert';
import 'package:agri_connect/core/enums/user_enums.dart';

class UserModel {
  final String id;
  final String? username;
  final String fullName;
  final String email;
  final UserType userType;
  final String? bio;
  final String? avatarUrl;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.userType,
    required this.createdAt,
    this.username,
    required this.email,
    this.bio,
    this.avatarUrl,
    this.phone,
    this.address,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    UserType? userType,
    String? bio,
    String? avatarUrl,
    String? phone,
    String? address,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String?,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      userType: (map['user_type'] as String).toUserTypeEnum(),
      bio: map['bio'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'user_type': userType.type,
      'bio': bio,
      'avatar_url': avatarUrl,
      'phone': phone,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
