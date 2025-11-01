part of 'student_time_table_cubit.dart';

abstract class StudentTimetableState extends Equatable {
  const StudentTimetableState();

  @override
  List<Object?> get props => [];
}

class StudentTimetableInitial extends StudentTimetableState {}

class StudentTimetableLoading extends StudentTimetableState {}

class StudentTimetableLoaded extends StudentTimetableState {
  final List<TimetableModel> timetables;
  const StudentTimetableLoaded(this.timetables);

  @override
  List<Object?> get props => [timetables];
}

class StudentTimetableError extends StudentTimetableState {
  final String message;
  const StudentTimetableError(this.message);

  @override
  List<Object?> get props => [message];
}
