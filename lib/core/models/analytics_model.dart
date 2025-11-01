import 'package:equatable/equatable.dart';

class AnalyticsModel extends Equatable {
  final int totalStudents;
  final int studentsVisitedToday;
  final int totalTeachers;
  final int teachersVisitedToday;
  final int studentsOnline;
  final int teachersOnline;
  final Map<String, double> weeklyActivity;

  const AnalyticsModel({
    required this.totalStudents,
    required this.studentsVisitedToday,
    required this.totalTeachers,
    required this.teachersVisitedToday,
    required this.studentsOnline,
    required this.teachersOnline,
    required this.weeklyActivity,
  });

  @override
  List<Object> get props => [
    totalStudents,
    studentsVisitedToday,
    totalTeachers,
    teachersVisitedToday,
    studentsOnline,
    teachersOnline,
    weeklyActivity,
  ];
}
