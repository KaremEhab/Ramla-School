import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/app/constants.dart';

part 'admin_time_table_state.dart';

class AdminTimetableCubit extends Cubit<AdminTimetableState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminTimetableCubit() : super(AdminTimetableInitial());

  Future<void> addOrUpdateTimetable(TimetableModel timetable) async {
    emit(AdminTimetableLoading());
    try {
      await _firestore
          .collection('timetables')
          .doc(timetable.id)
          .set(timetable.toMap());
      emit(AdminTimetableSuccess("Timetable saved successfully"));
    } catch (e) {
      emit(AdminTimetableError("Failed to save timetable: $e"));
    }
  }

  Future<void> fetchTimetables(Grade grade, int classNumber) async {
    emit(AdminTimetableLoading());
    try {
      final query = await _firestore
          .collection('timetables')
          .where('grade', isEqualTo: grade.label)
          .where('classNumber', isEqualTo: classNumber)
          .get();

      final timetables = query.docs
          .map((doc) => TimetableModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();

      emit(AdminTimetableLoaded(timetables));
    } catch (e) {
      emit(AdminTimetableError("Error fetching timetables: $e"));
    }
  }

  Future<void> deleteTimetable(String id) async {
    try {
      await _firestore.collection('timetables').doc(id).delete();
      emit(AdminTimetableSuccess("Timetable deleted successfully"));
    } catch (e) {
      emit(AdminTimetableError("Failed to delete timetable: $e"));
    }
  }

  /// ✅ Fetch all teachers from Firestore
  Future<List<TeacherModel>> fetchAllTeachers() async {
    try {
      final query = await _firestore
          .collection('users')
          .where('role', isEqualTo: UserRole.teacher.name)
          .get();

      return query.docs
          .map((doc) => TeacherModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      emit(AdminTimetableError("Error fetching teachers: $e"));
      return [];
    }
  }
}
