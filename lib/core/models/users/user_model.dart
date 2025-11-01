import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/admin_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';

abstract class UserModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String imageUrl;
  final UserRole role;
  final UserStatus status;
  final Gender gender;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.imageUrl,
    required this.role,
    required this.status,
    required this.gender,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    imageUrl,
    role,
    status,
    gender,
    createdAt,
  ];

  UserModel copyWithJson(Map<String, dynamic> json) {
    return UserModel.fromMap(json);
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    final role = UserRole.fromString(map['role']);
    switch (role) {
      case UserRole.student:
        return StudentModel.fromMap(map);
      case UserRole.teacher:
        return TeacherModel.fromMap(map);
      case UserRole.admin:
        return AdminModel.fromMap(map);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'imageUrl': imageUrl,
      'role': role.name,
      'status': status.name,
      'gender': gender.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? imageUrl,
    UserRole? role,
    UserStatus? status,
    Gender? gender,
    DateTime? createdAt,
  });

  // ✅ Add these two helpers
  String toJsonString() => jsonEncode(toMap());

  static UserModel fromJsonString(String source) =>
      UserModel.fromMap(jsonDecode(source));
}
