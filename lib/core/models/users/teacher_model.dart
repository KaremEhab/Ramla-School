import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/subject_model.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

class TeacherModel extends UserModel {
  final List<SchoolSubject> subjects;
  final String? _fullName;
  final List<int> grades; // ✅ Now it's plural

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
    required this.grades, // ✅ plural
    String? fullName,
  }) : _fullName = fullName,
       super(role: UserRole.teacher);

  /// Computed full name (uses provided fullName if any)
  @override
  String get fullName => _fullName ?? '$firstName $lastName';

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'subjects': subjects.map((s) => s.name).toList(), // ✅ enum names
      'fullName': fullName,
      'grades': grades, // ✅ plural and saved as list<int>
    };
  }

  factory TeacherModel.fromMap(Map<String, dynamic> map) {
    return TeacherModel(
      id: map['id'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      grades: (map['grades'] as List<dynamic>? ?? [])
          .map((g) => g is int ? g : int.tryParse(g.toString()) ?? 0)
          .toList(), // ✅ safely parse list<int>
      status: UserStatus.fromString(map['status']),
      gender: Gender.fromString(map['gender']),
      createdAt: (() {
        final value = map['createdAt'];
        if (value is Timestamp) return value.toDate();
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (_) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      })(),
      subjects: (map['subjects'] as List<dynamic>? ?? [])
          .map((s) => SchoolSubject.fromString(s.toString()))
          .toList(),
      fullName: map['fullName'],
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
    List<int>? grades,
    Gender? gender,
    DateTime? createdAt,
    List<SchoolSubject>? subjects,
    String? fullName,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      grades: grades ?? this.grades, // ✅ fixed naming
      gender: gender ?? this.gender,
      createdAt: createdAt ?? this.createdAt,
      subjects: subjects ?? this.subjects,
      fullName: fullName ?? _fullName,
    );
  }
}
