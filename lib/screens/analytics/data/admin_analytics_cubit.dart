import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Note: Assuming UserStatus and UserRole are defined in constants.dart
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/analytics_model.dart'; // Assuming AnalyticsModel is defined here

part 'admin_analytics_state.dart';

class AdminAnalyticsCubit extends Cubit<AdminAnalyticsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _userSubscription;

  AdminAnalyticsCubit() : super(AdminAnalyticsInitial());

  void fetchAnalyticsData() {
    emit(AdminAnalyticsLoading());

    // Stop any previous subscription
    _userSubscription?.cancel();

    try {
      // Stream documents from the 'users' collection to listen for real-time changes
      _userSubscription = _firestore
          .collection('users')
          .snapshots()
          .listen(
            (snapshot) async {
              // Use synchronous calls inside the listener to calculate real-time stats
              final totalStudents = snapshot.docs
                  .where((doc) => doc.data()['role'] == UserRole.student.name)
                  .length;
              final totalTeachers = snapshot.docs
                  .where((doc) => doc.data()['role'] == UserRole.teacher.name)
                  .length;

              final studentsOnline = snapshot.docs
                  .where((doc) => doc.data()['role'] == UserRole.student.name)
                  .where(
                    (doc) => doc.data()['status'] == UserStatus.online.name,
                  )
                  .length;

              final teachersOnline = snapshot.docs
                  .where((doc) => doc.data()['role'] == UserRole.teacher.name)
                  .where(
                    (doc) => doc.data()['status'] == UserStatus.online.name,
                  )
                  .length;

              // --- Mock/Estimate Daily Visits & Weekly Activity ---
              // These still rely on mock/estimates as detailed login history needs complex fields/queries.
              final studentsVisitedToday = (totalStudents * 0.53).round();
              final teachersVisitedToday = (totalTeachers * 0.35).round();

              final weeklyActivity = {
                'activeStudents':
                    studentsOnline / totalStudents.clamp(1, double.infinity),
                'inactiveStudents':
                    (totalStudents - studentsOnline) /
                    totalStudents.clamp(1, double.infinity),
                'activeTeachers':
                    teachersOnline / totalTeachers.clamp(1, double.infinity),
                'inactiveTeachers':
                    (totalTeachers - teachersOnline) /
                    totalTeachers.clamp(1, double.infinity),
              };
              // Clamp total to 1 to avoid division by zero if lists are empty

              final analyticsModel = AnalyticsModel(
                totalStudents: totalStudents,
                studentsVisitedToday: studentsVisitedToday,
                totalTeachers: totalTeachers,
                teachersVisitedToday: teachersVisitedToday,
                studentsOnline: studentsOnline,
                teachersOnline: teachersOnline,
                weeklyActivity: weeklyActivity,
              );

              emit(AdminAnalyticsLoaded(analyticsModel));
            },
            onError: (error) {
              log('Real-time analytics error: $error');
              emit(
                AdminAnalyticsFailure(
                  'فشل تحديث التحليلات في الوقت الفعلي: ${error.toString()}',
                ),
              );
            },
          );
    } catch (e) {
      log('Initial analytics error: $e');
      emit(
        AdminAnalyticsFailure('فشل تحميل التحليلات الأولية: ${e.toString()}'),
      );
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
