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

  // Helper getter
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

  // This factory constructor is the key.
  // It reads the 'role' from the map and decides which
  // concrete class to instantiate.
  factory UserModel.fromMap(Map<String, dynamic> map) {
    // Read the role to decide which model to create
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

  // This method will be implemented by subclasses
  Map<String, dynamic> toMap();

  // This method will also be implemented by subclasses
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
}
