import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/lesson_model.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';

class MockTimetableService {
  static final Random _rand = Random();

  // --- Constants ---
  static const int lessonDuration = 45; // minutes
  static const int breakDuration = 15; // minutes
  static const int afterFirstBreakDelay = 5; // minutes after 1st break
  static const int lessonsPerDay = 7;

  // --- Fake Teachers ---
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
      subjects: [],
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
      subjects: [],
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
      subjects: [],
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
      subjects: [],
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
      subjects: [],
      fullName: 'أ. أحمد',
    ),
  ];

  // --- All Subjects ---
  static final List<SchoolSubject> _subjects = [
    SchoolSubject.math,
    SchoolSubject.science,
    SchoolSubject.fitness,
    SchoolSubject.music,
    SchoolSubject.islamic,
    SchoolSubject.computer,
    SchoolSubject.geography,
    SchoolSubject.english,
    SchoolSubject.arabic,
    SchoolSubject.houseEconomics,
    SchoolSubject.practicalStudies,
    SchoolSubject.art,
  ];

  /// Generates a full month of timetables for every class in every grade
  static List<TimetableModel> generateOctoberTimetables() {
    final List<TimetableModel> all = [];

    final year = 2025;
    final month = 10;

    for (final grade in Grade.values) {
      int classCount = _getClassCount(grade);

      for (int classNum = 1; classNum <= classCount; classNum++) {
        // Loop over each day in October
        for (int day = 1; day <= 31; day++) {
          final date = DateTime(year, month, day);

          // Skip Fridays and Saturdays
          if (date.weekday == DateTime.friday ||
              date.weekday == DateTime.saturday)
            continue;

          all.add(
            TimetableModel(
              id: '${grade.name}_${classNum}_${date.toIso8601String()}',
              grade: grade,
              classNumber: classNum,
              date: date,
              lessons: _generateDailyLessons(grade),
            ),
          );
        }
      }
    }

    return all;
  }

  // --- Helpers ---
  static int _getClassCount(Grade grade) {
    switch (grade) {
      case Grade.grade6:
        return 7;
      case Grade.grade7:
        return 6;
      case Grade.grade8:
        return 6;
      case Grade.grade9:
        return 5;
    }
  }

  static List<LessonModel> _generateDailyLessons(Grade grade) {
    final List<LessonModel> lessons = [];
    DateTime currentTime = DateTime(
      2025,
      10,
      1,
      7,
      45,
    ); // School starts at 7:45 AM

    for (int i = 0; i < lessonsPerDay; i++) {
      // Add breaks after lesson 2 and 5
      if (i == 2 || i == 5) {
        final start = currentTime;
        final end = start.add(Duration(minutes: breakDuration));

        String breakName = (i == 2) ? 'الفرصة الاولى' : 'الفرصة الثانية';

        lessons.add(
          LessonModel(
            id: 'break_${i + 1}',
            isBreak: true,
            duration: breakDuration,
            startTime: Timestamp.fromDate(start),
            endTime: Timestamp.fromDate(end),
            subject: null,
            teacher: null,
            breakTitle: breakName, // <-- add this
          ),
        );

        // If your LessonModel supports a `title` for breaks, set it:
        // lessons.last.title = breakName;

        // Apply the 5-minute delay after every break
        currentTime = end.add(Duration(minutes: afterFirstBreakDelay));
      }

      // --- Create lesson ---
      final subject = _getRandomSubjectForGrade(grade);
      final teacher = _teachers[_rand.nextInt(_teachers.length)];
      final start = currentTime;
      final end = start.add(Duration(minutes: lessonDuration));

      lessons.add(
        LessonModel(
          id: 'lesson_${subject.name}_${start.hour}${start.minute}',
          subject: subject,
          teacher: teacher,
          isBreak: false,
          duration: lessonDuration,
          startTime: Timestamp.fromDate(start),
          endTime: Timestamp.fromDate(end),
          breakTitle: '',
          documentUrls: _generateRandomDocuments(), // 👈 add this line
        ),
      );

      currentTime = end;
    }

    return lessons;
  }

  static List<String> _generateRandomDocuments() {
    final List<String> docs = [
      'https://example.com/lesson_notes.pdf',
      'https://example.com/homework_sheet.pdf',
    ];
    int count = _rand.nextInt(3); // 0, 1 or 2 documents
    return List.generate(count, (_) => docs[_rand.nextInt(docs.length)]);
  }

  static SchoolSubject _getRandomSubjectForGrade(Grade grade) {
    final allowed = switch (grade) {
      Grade.grade6 =>
        _subjects
            .where(
              (s) =>
                  s != SchoolSubject.art && s != SchoolSubject.houseEconomics,
            )
            .toList(),
      Grade.grade7 =>
        _subjects
            .where(
              (s) =>
                  s != SchoolSubject.practicalStudies &&
                  s != SchoolSubject.houseEconomics,
            )
            .toList(),
      Grade.grade8 =>
        _subjects
            .where(
              (s) =>
                  s != SchoolSubject.art && s != SchoolSubject.houseEconomics,
            )
            .toList(),
      Grade.grade9 =>
        _subjects
            .where(
              (s) =>
                  s != SchoolSubject.practicalStudies &&
                  s != SchoolSubject.houseEconomics,
            )
            .toList(),
    };
    return allowed[_rand.nextInt(allowed.length)];
  }
}
