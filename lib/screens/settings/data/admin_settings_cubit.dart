import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/admin_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

part 'admin_settings_state.dart';

class AdminSettingsCubit extends Cubit<AdminSettingsState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminSettingsCubit() : super(AdminSettingsInitial());

  // Function to create a new user account (Admin, Teacher, or Student)
  Future<void> createNewUserAccount({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required UserRole role,
    Gender gender = Gender.female,
    List<SchoolSubject>? subjects,
    List<int>? grades,
    int? grade,
    int? classNumber,
  }) async {
    emit(AdminSettingsLoading());

    try {
      // 1️⃣ Create the account in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 2️⃣ Prepare model based on role
      UserModel userModel;

      final now = DateTime.now();
      final fullName = '$firstName $lastName';

      switch (role) {
        case UserRole.admin:
          userModel = AdminModel(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            imageUrl: '',
            status: UserStatus.online,
            gender: gender,
            createdAt: now,
          );
          break;

        case UserRole.teacher:
          userModel = TeacherModel(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            imageUrl: '',
            status: UserStatus.online,
            gender: gender,
            createdAt: now,
            fullName: fullName,
            subjects: subjects ?? [],
            grades: grades ?? [],
          );
          break;

        case UserRole.student:
          userModel = StudentModel(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            imageUrl: '',
            status: UserStatus.online,
            gender: gender,
            createdAt: now,
            grade: grade ?? 6,
            classNumber: classNumber ?? 1,
          );
          break;
      }

      // 3️⃣ Save to correct collection
      final collectionName = role == UserRole.admin ? 'admins' : 'users';
      await _firestore
          .collection(collectionName)
          .doc(uid)
          .set(userModel.toMap());

      emit(AdminSettingsSuccess('تم إنشاء حساب ${userModel.fullName} بنجاح!'));
    } on FirebaseAuthException catch (e) {
      emit(AdminSettingsFailure(e.message ?? 'فشل إنشاء الحساب'));
    } catch (e) {
      emit(AdminSettingsFailure(e.toString()));
    }
  }

  // --- Add other administrative functions here (fetch, delete, etc.) if needed ---
  // For now, we rely on AdminTimetableCubit for fetching teachers/students lists

  // You will likely want the fetch teachers/students logic from AdminTimetableCubit in here
  // to manage the state within the new cubit. For now, we'll keep the call in the screen.
}
