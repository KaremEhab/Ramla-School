part of 'teacher_time_table_cubit.dart';

abstract class TeacherTimetableState extends Equatable {
  const TeacherTimetableState();

  @override
  List<Object?> get props => [];
}

class TeacherTimetableInitial extends TeacherTimetableState {}

class TeacherTimetableLoading extends TeacherTimetableState {}

class TeacherTimetableLoaded extends TeacherTimetableState {
  final List<TimetableModel> timetables;
  const TeacherTimetableLoaded(this.timetables);

  @override
  List<Object?> get props => [timetables];
}

class TeacherTimetableError extends TeacherTimetableState {
  final String message;
  const TeacherTimetableError(this.message);

  @override
  List<Object?> get props => [message];
}
