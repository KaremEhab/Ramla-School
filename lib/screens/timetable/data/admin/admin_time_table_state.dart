part of 'admin_time_table_cubit.dart';

abstract class AdminTimetableState extends Equatable {
  const AdminTimetableState();

  @override
  List<Object?> get props => [];
}

class AdminTimetableInitial extends AdminTimetableState {}

class AdminTimetableLoading extends AdminTimetableState {}

class AdminTimetableLoaded extends AdminTimetableState {
  final List<TimetableModel> timetables;
  const AdminTimetableLoaded(this.timetables);

  @override
  List<Object?> get props => [timetables];
}

class AdminTimetableError extends AdminTimetableState {
  final String message;
  const AdminTimetableError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminTimetableSuccess extends AdminTimetableState {
  final String message;
  const AdminTimetableSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
