import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/app/constants.dart';

part 'student_time_table_state.dart';

class StudentTimetableCubit extends Cubit<StudentTimetableState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StudentTimetableCubit() : super(StudentTimetableInitial());

  Future<void> fetchStudentTimetable(int grade, int classNumber) async {
    emit(StudentTimetableLoading());
    try {
      // Query all timetables for this grade and classNumber
      final querySnapshot = await _firestore
          .collection('timetables')
          .where('grade', isEqualTo: grade)
          .where('classNumber', isEqualTo: classNumber)
          .orderBy('date') // Optional: sort by date
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        log('Found ${querySnapshot.docs.length} documents.');

        final timetables = querySnapshot.docs.map((doc) {
          return TimetableModel.fromMap({...doc.data(), 'id': doc.id});
        }).toList();

        emit(StudentTimetableLoaded(timetables));
      } else {
        log('No timetables found for grade $grade, class $classNumber.');
        emit(StudentTimetableLoaded([]));
      }
    } catch (e) {
      log('Error fetching timetables: $e');
      emit(StudentTimetableError("Error fetching student timetable: $e"));
    }
  }
}
