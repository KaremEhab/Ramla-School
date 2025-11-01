// lesson_model.dart
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';

class LessonModel {
  final String id;
  final SchoolSubject? subject;
  final TeacherModel? teacher;
  final bool isBreak;
  final String? breakTitle;
  final int duration; // in minutes
  final Timestamp startTime;
  final Timestamp endTime;
  final List<String> documentUrls;

  const LessonModel({
    required this.id,
    this.subject,
    this.teacher,
    this.isBreak = false,
    this.breakTitle,
    required this.duration,
    required this.startTime,
    required this.endTime,
    this.documentUrls = const [],
  });

  LessonModel copyWith({
    String? id,
    SchoolSubject? subject,
    TeacherModel? teacher,
    bool? isBreak,
    String? breakTitle,
    int? duration,
    Timestamp? startTime,
    Timestamp? endTime,
    List<String>? documentUrls,
  }) {
    return LessonModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      isBreak: isBreak ?? this.isBreak,
      breakTitle: breakTitle ?? this.breakTitle,
      duration: duration ?? this.duration,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      documentUrls: documentUrls ?? this.documentUrls,
    );
  }

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
      breakTitle: data['breakTitle'],
      duration: data['duration'] ?? 0,
      startTime: data['startTime'] ?? Timestamp.now(),
      endTime: data['endTime'] ?? Timestamp.now(),
      documentUrls: (data['documentUrls'] as List?)?.cast<String>() ?? [],
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

// ------------------- DATA MODELS -------------------

abstract class TimelineEntry {
  final String startTime;
  final String endTime;
  const TimelineEntry({required this.startTime, required this.endTime});
}

class LessonEntry extends TimelineEntry {
  final String subject;
  final String teacher;
  final String grade;
  final String classNumber;
  final int lessonIndex;
  final String duration;
  final String? extraInfo;
  final Color color;
  final List<String> documentUrls;

  const LessonEntry({
    required this.subject,
    required this.teacher,
    required this.grade,
    required this.classNumber,
    required this.lessonIndex,
    required this.duration,
    required this.color,
    this.extraInfo = '',
    required super.startTime,
    required super.endTime,
    this.documentUrls = const [],
  });
}

class BreakEntry extends TimelineEntry {
  final String title;
  const BreakEntry({
    required this.title,
    required super.startTime,
    required super.endTime,
  });
}

class DaySchedule {
  final DateTime date;
  final List<TimelineEntry> entries;

  DaySchedule({required this.date, required this.entries});
}
