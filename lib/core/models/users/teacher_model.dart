import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/lesson_model.dart';
import 'package:ramla_school/core/models/subject_model.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

class TeacherModel extends UserModel {
  final List<LessonModel> subjects;
  final String? _fullName;

  const TeacherModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.imageUrl,
    required super.status,
    required super.gender,
    required super.createdAt,
    required this.subjects,
    String? fullName, // optional custom full name
  }) : _fullName = fullName,
       super(role: UserRole.teacher);

  /// Computed full name (uses provided fullName if any)
  String get fullName => _fullName ?? '$firstName $lastName';

  @override
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
      'createdAt': Timestamp.fromDate(createdAt),
      'subjects': subjects.map((s) => s.toMap()).toList(),
      'fullName': fullName, // Include full name in map
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      status: UserStatus.fromString(map['status']),
      gender: Gender.fromString(map['gender']),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      subjects:
          (map['subjects'] as List<dynamic>?)
              ?.map((e) => LessonModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      fullName: map['fullName'], // Safe to load from Firebase if exists
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
    List<LessonModel>? subjects,
    String? fullName,
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
      subjects: subjects ?? this.subjects,
      fullName: fullName ?? _fullName,
    );
  }
}
