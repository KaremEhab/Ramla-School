import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/lesson_model.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';

/// ✅ خدمة لتوليد جداول زمنية وهمية للمعلمين بين أكتوبر وديسمبر
class MockTeacherTimetableService {
  static final Random _rand = Random();

  static const int lessonDuration = 45; // مدة الحصة (دقيقة)
  static const int breakDuration = 15; // مدة الاستراحة (دقيقة)
  static const int afterBreakDelay = 5; // تأخير بعد الاستراحة (دقيقة)

  // --- 🔹 قائمة الأساتذة الوهمية ---
  static final List<TeacherModel> _teachers = [
    TeacherModel(
      id: 't1',
      firstName: 'محمد',
      lastName: '',
      email: 'mohamed@example.com',
      imageUrl: '',
      status: UserStatus.online,
      gender: Gender.male,
      createdAt: DateTime.now(),
      subjects: [SchoolSubject.math, SchoolSubject.science],
      fullName: 'أ. محمد',
    ),
    TeacherModel(
      id: 't2',
      firstName: 'فاطمة',
      lastName: '',
      email: 'fatma@example.com',
      imageUrl: '',
      status: UserStatus.online,
      gender: Gender.female,
      createdAt: DateTime.now(),
      subjects: [SchoolSubject.arabic, SchoolSubject.islamic],
      fullName: 'أ. فاطمة',
    ),
    TeacherModel(
      id: 't3',
      firstName: 'علي',
      lastName: '',
      email: 'ali@example.com',
      imageUrl: '',
      status: UserStatus.online,
      gender: Gender.male,
      createdAt: DateTime.now(),
      subjects: [SchoolSubject.computer, SchoolSubject.english],
      fullName: 'أ. علي',
    ),
    TeacherModel(
      id: 't4',
      firstName: 'سارة',
      lastName: '',
      email: 'sara@example.com',
      imageUrl: '',
      status: UserStatus.online,
      gender: Gender.female,
      createdAt: DateTime.now(),
      subjects: [SchoolSubject.art, SchoolSubject.music],
      fullName: 'أ. سارة',
    ),
    TeacherModel(
      id: 't5',
      firstName: 'أحمد',
      lastName: '',
      email: 'ahmed@example.com',
      imageUrl: '',
      status: UserStatus.online,
      gender: Gender.male,
      createdAt: DateTime.now(),
      subjects: [SchoolSubject.geography, SchoolSubject.practicalStudies],
      fullName: 'أ. أحمد',
    ),
  ];

  /// 🔹 توليد الجداول الزمنية لكل المعلمين بين أكتوبر وديسمبر
  static List<TimetableModel> generateTeacherTimetables() {
    final List<TimetableModel> timetables = [];
    const int year = 2025;

    for (int month = 10; month <= 12; month++) {
      for (final teacher in _teachers) {
        for (int day = 1; day <= 28; day++) {
          final date = DateTime(year, month, day);

          // تخطي الجمعة والسبت
          if (date.weekday == DateTime.friday ||
              date.weekday == DateTime.saturday)
            continue;

          final lessons = _generateDailyLessons(teacher, date);

          if (lessons.isNotEmpty) {
            timetables.add(
              TimetableModel(
                id: '${teacher.id}_${date.toIso8601String()}',
                grade: Grade.values[_rand.nextInt(Grade.values.length)],
                classNumber: _rand.nextInt(5) + 1,
                date: date,
                lessons: lessons,
              ),
            );
          }
        }
      }
    }

    // 🔍 Debug log
    print('✅ Generated ${timetables.length} timetables in total.');
    print('Example:');
    for (var t in timetables.take(5)) {
      print(
        '${t.lessons.first.teacher?.fullName ?? "??"} - ${t.date.day}/${t.date.month}/${t.date.year}',
      );
    }

    return timetables;
  }

  /// 🔸 توليد جدول يومي لأستاذ معين
  static List<LessonModel> _generateDailyLessons(
    TeacherModel teacher,
    DateTime date,
  ) {
    final List<LessonModel> lessons = [];
    DateTime currentTime = DateTime(date.year, date.month, date.day, 8, 0);

    // عدد الحصص بين 3 إلى 6 يومياً
    final int todayLessonsCount = 3 + _rand.nextInt(4);

    for (int i = 0; i < todayLessonsCount; i++) {
      // أضف استراحة بعد الحصة الثانية
      if (i == 2) {
        final breakStart = currentTime;
        final breakEnd = breakStart.add(const Duration(minutes: breakDuration));

        lessons.add(
          LessonModel(
            id: 'break_${teacher.id}_$i',
            isBreak: true,
            duration: breakDuration,
            startTime: Timestamp.fromDate(breakStart),
            endTime: Timestamp.fromDate(breakEnd),
            subject: null,
            teacher: null,
            breakTitle: 'استراحة قصيرة',
          ),
        );

        currentTime = breakEnd.add(const Duration(minutes: afterBreakDelay));
        continue;
      }

      // اختر مادة من مواد المدرس
      final subject = teacher.subjects[_rand.nextInt(teacher.subjects.length)];
      final start = currentTime;
      final end = start.add(const Duration(minutes: lessonDuration));

      lessons.add(
        LessonModel(
          id: '${teacher.id}_${subject.name}_$i',
          subject: subject,
          teacher: teacher,
          isBreak: false,
          duration: lessonDuration,
          startTime: Timestamp.fromDate(start),
          endTime: Timestamp.fromDate(end),
          breakTitle: '',
          documentUrls: _generateRandomDocuments(),
        ),
      );

      currentTime = end;
    }

    return lessons;
  }

  /// 🔸 إنشاء روابط عشوائية للملفات
  static List<String> _generateRandomDocuments() {
    final docs = [
      'https://example.com/homework_sheet.pdf',
      'https://example.com/lesson_slides.pdf',
      'https://example.com/revision_notes.pdf',
    ];

    final count = _rand.nextInt(3);
    return List.generate(count, (_) => docs[_rand.nextInt(docs.length)]);
  }

  /// 🔹 الحصول على معلم بالاسم الكامل
  static TeacherModel? getTeacherByName(String name) {
    try {
      return _teachers.firstWhere((t) => t.fullName == name);
    } catch (_) {
      return null;
    }
  }
}
