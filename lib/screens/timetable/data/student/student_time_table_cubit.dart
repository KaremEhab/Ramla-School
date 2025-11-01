import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/app/constants.dart';

part 'student_time_table_state.dart';

class StudentTimetableCubit extends Cubit<StudentTimetableState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StudentTimetableCubit() : super(StudentTimetableInitial());

  Future<void> fetchStudentTimetable(Grade grade, int classNumber) async {
    emit(StudentTimetableLoading());
    try {
      final query = await _firestore
          .collection('timetables')
          .where('grade', isEqualTo: grade.label)
          .where('classNumber', isEqualTo: classNumber)
          .get();

      final timetables = query.docs
          .map((doc) => TimetableModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      emit(StudentTimetableLoaded(timetables));
    } catch (e) {
      emit(StudentTimetableError("Error fetching student timetable: $e"));
    }
  }
}
