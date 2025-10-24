import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

class StudentModel extends UserModel {
  final String className;
  final String classNumber;

  const StudentModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.imageUrl,
    required super.status,
    required super.gender,
    required super.createdAt,
    required this.className,
    required this.classNumber,
  }) : super(role: UserRole.student); // Role is fixed

  // Helper getter for the example: "طالبة بالصف التاسع/آول"
  String get fullClassDescription {
    return 'طالبة بالصف $className/$classNumber';
  }

  @override
  List<Object?> get props => [
    ...super.props, // Gets all props from base UserModel
    className,
    classNumber,
  ];

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'imageUrl': imageUrl,
      'role': role.name, // Saves enum as string 'student'
      'status': status.name, // Saves enum as string 'online' or 'offline'
      'gender': gender.name,
      'createdAt': Timestamp.fromDate(createdAt),
      // Student-specific fields
      'className': className,
      'classNumber': classNumber,
    };
  }

  // ** THE FIX IS HERE **
  // Removed the 'role' parameter from this factory
  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      // 'role' is not needed here, it's set in the constructor
      status: UserStatus.fromString(map['status']),
      gender: Gender.fromString(map['gender']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      className: map['className'] ?? '',
      classNumber: map['classNumber'] ?? '',
    );
  }

  @override
  StudentModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? imageUrl,
    UserRole? role, // Kept for flexibility, though it shouldn't change
    UserStatus? status,
    Gender? gender,
    DateTime? createdAt,
    String? className,
    String? classNumber,
  }) {
    return StudentModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      className: className ?? this.className,
      classNumber: classNumber ?? this.classNumber,
    );
  }
}
