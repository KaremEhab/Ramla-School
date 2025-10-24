import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

class TeacherModel extends UserModel {
  // You can add teacher-specific fields here later
  // e.g., final List<String> subjects;

  const TeacherModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.imageUrl,
    required super.status,
    required super.gender,
    required super.createdAt,
    // required this.subjects,
  }) : super(role: UserRole.teacher); // Role is fixed

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'imageUrl': imageUrl,
      'role': role.name, // Saves enum as string 'teacher'
      'status': status.name,
      'gender': gender.name,
      'createdAt': Timestamp.fromDate(createdAt),
      // 'subjects': subjects,
    };
  }

  // ** THE FIX IS HERE **
  // Removed the 'role' parameter from this factory
  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // 'role' is not needed here, it's set in the constructor
      status: UserStatus.fromString(map['status']),
      gender: Gender.fromString(map['gender']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      // subjects: List<String>.from(map['subjects'] ?? []),
    );
  }

  @override
  TeacherModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? imageUrl,
    UserRole? role,
    UserStatus? status,
    Gender? gender,
    DateTime? createdAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
