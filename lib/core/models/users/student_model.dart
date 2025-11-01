import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

class StudentModel extends UserModel {
  final int grade;
  final int classNumber;

  const StudentModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.imageUrl,
    required super.status,
    required super.gender,
    required super.createdAt,
    required this.grade,
    required this.classNumber,
  }) : super(role: UserRole.student); // Role is fixed

  // Helper getter for the example: "طالبة بالصف التاسع/آول"
  String get fullClassDescription {
    return 'طالبة بالصف $grade/$classNumber';
  }

  @override
  List<Object?> get props => [
    ...super.props, // Gets all props from base UserModel
    grade,
    classNumber,
  ];

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      // Student-specific fields
      'grade': grade,
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
      createdAt: (() {
        final value = map['createdAt'];
        if (value is Timestamp) return value.toDate();
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (_) {
            // fallback for Firestore's human-readable date format
            return DateTime.now();
          }
        }
        return DateTime.now();
      })(),
      grade: map['grade'] ?? 1,
      classNumber: map['classNumber'] ?? 1,
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
    int? grade,
    int? classNumber,
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
      grade: grade ?? this.grade,
      classNumber: classNumber ?? this.classNumber,
    );
  }
}
