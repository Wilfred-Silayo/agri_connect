import 'package:agri_connect/core/enums/user_enums.dart';

class User {
  final String id;
  final String username;
  final String? fullName;
  final String? email;
  final UserType userType;
  final String? bio;
  final String? avatarUrl;
  final String? phone;
  final String? address;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.userType,
    required this.createdAt,
    this.fullName,
    this.email,
    this.bio,
    this.avatarUrl,
    this.phone,
    this.address,
  });
}
