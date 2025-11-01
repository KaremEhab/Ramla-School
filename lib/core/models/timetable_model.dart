import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'lesson_model.dart';

class TimetableModel {
  final String id; // e.g. "2025_grade7_3_2025-11-01"
  final Grade grade;
  final int classNumber;
  final DateTime date;
  final List<LessonModel> lessons;

  const TimetableModel({
    required this.id,
    required this.grade,
    required this.classNumber,
    required this.date,
    required this.lessons,
  });

  /// Creates a document ID based on your flat structure
  static String generateId({
    required int year,
    required Grade grade,
    required int classNumber,
    required DateTime date,
  }) {
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return "${year}_${grade.label}_${classNumber}_$formattedDate";
  }

  factory TimetableModel.fromMap(Map<String, dynamic> data) {
    return TimetableModel(
      id: data['id'] ?? '',
      grade: Grade.values.firstWhere(
        (g) => g.index + 6 == (data['grade'] is int ? data['grade'] : 6),
        orElse: () => Grade.grade6,
      ),
      classNumber: data['classNumber'] ?? 1,
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
      lessons: (data['lessons'] as List<dynamic>? ?? [])
          .map((e) => LessonModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grade': grade.index + 6, // store as int (6,7,8,...)
      'classNumber': classNumber,
      'date': Timestamp.fromDate(date),
      'lessons': lessons.map((l) => l.toMap()).toList(),
    };
  }

  // ✅ Add this method
  TimetableModel copyWith({
    String? id,
    Grade? grade,
    int? classNumber,
    DateTime? date,
    List<LessonModel>? lessons,
  }) {
    return TimetableModel(
      id: id ?? this.id,
      grade: grade ?? this.grade,
      classNumber: classNumber ?? this.classNumber,
      date: date ?? this.date,
      lessons: lessons ?? this.lessons,
    );
  }
}
