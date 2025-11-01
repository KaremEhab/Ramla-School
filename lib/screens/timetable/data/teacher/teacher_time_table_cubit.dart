import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';

part 'teacher_time_table_state.dart';

class TeacherTimetableCubit extends Cubit<TeacherTimetableState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TeacherTimetableCubit() : super(TeacherTimetableInitial());

  Future<void> fetchTeacherTimetables(TeacherModel teacher) async {
    emit(TeacherTimetableLoading());
    try {
      final query = await _firestore.collection('timetables').get();
      final all = query.docs
          .map((doc) => TimetableModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      // Filter timetables where any lesson.teacher.id == teacher.id
      final filtered = all
          .where((t) => t.lessons.any((l) => l.teacher?.id == teacher.id))
          .toList();

      emit(TeacherTimetableLoaded(filtered));
    } catch (e) {
      emit(TeacherTimetableError("Error fetching teacher timetable: $e"));
    }
  }
}
