import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'lesson_model.dart';

class TimetableModel {
  final String id;
  final Grade grade;
  final int classNumber; // e.g. 1, 2, 3 ...
  final DateTime date;
  final List<LessonModel> lessons;

  const TimetableModel({
    required this.id,
    required this.grade,
    required this.classNumber,
    required this.date,
    required this.lessons,
  });

  factory TimetableModel.fromMap(Map<String, dynamic> data) {
    return TimetableModel(
      id: data['id'] ?? '',
      grade: Grade.values.firstWhere(
        (g) => g.label == data['grade'],
        orElse: () => Grade.grade6,
      ),
      classNumber: data['classNumber'] ?? 1,
      date: (data['date'] as Timestamp).toDate(),
      lessons: (data['lessons'] as List<dynamic>? ?? [])
          .map((e) => LessonModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'grade': grade.label,
      'classNumber': classNumber,
      'date': Timestamp.fromDate(date),
      'lessons': lessons.map((l) => l.toMap()).toList(),
    };
  }
}
