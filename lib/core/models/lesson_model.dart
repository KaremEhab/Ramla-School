import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';

class LessonModel {
  final String id;
  final SchoolSubject? subject;
  final TeacherModel? teacher;
  final bool isBreak;
  final String breakTitle;
  final int duration; // minutes
  final Timestamp startTime;
  final Timestamp endTime;
  final List<String> documentUrls;

  const LessonModel({
    required this.id,
    this.subject,
    this.teacher,
    required this.isBreak,
    required this.breakTitle,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.documentUrls = const [],
  });

  factory LessonModel.fromMap(Map<String, dynamic> data) {
    return LessonModel(
      id: data['id'] ?? '',
      subject: data['subject'] != null
          ? SchoolSubject.values.firstWhere(
              (s) => s.name == data['subject'],
              orElse: () => SchoolSubject.math,
            )
          : null,
      teacher: data['teacher'] != null
          ? TeacherModel.fromMap(Map<String, dynamic>.from(data['teacher']))
          : null,
      isBreak: data['isBreak'] ?? false,
      breakTitle: data['breakTitle'] ?? '',
      duration: data['duration'] ?? 0,
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      documentUrls: data['documentUrls'] != null
          ? List<String>.from(data['documentUrls'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subject': subject?.name,
      'teacher': teacher?.toMap(),
      'isBreak': isBreak,
      'breakTitle': breakTitle,
      'duration': duration,
      'startTime': startTime,
      'endTime': endTime,
      'documentUrls': documentUrls,
    };
  }
}
