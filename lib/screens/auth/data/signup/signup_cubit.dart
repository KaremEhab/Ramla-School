import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/admin_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  SignupCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(SignupInitial());

  Future<void> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required UserRole role,
    String? imageUrl,
    Gender gender = Gender.female,
    List<SchoolSubject>? subjects,
    int? grade,
    int? classNumber,
  }) async {
    emit(SignupLoading());

    try {
      // 1️⃣ Create the account in Firebase Auth
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String uid = userCredential.user!.uid;

      // 2️⃣ Prepare model based on role
      UserModel userModel;

      final now = DateTime.now();
      imageUrl ??= ''; // default empty image

      switch (role) {
        case UserRole.admin:
          userModel = AdminModel(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            imageUrl: imageUrl,
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
            imageUrl: imageUrl,
            status: UserStatus.online,
            gender: gender,
            createdAt: now,
            subjects: subjects ?? [],
          );
          break;

        case UserRole.student:
          userModel = StudentModel(
            id: uid,
            firstName: firstName,
            lastName: lastName,
            email: email,
            imageUrl: imageUrl,
            status: UserStatus.online,
            gender: gender,
            createdAt: now,
            grade: grade ?? 1,
            classNumber: classNumber ?? 1,
          );
          break;
      }

      // 3️⃣ Store user data in Firestore
      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      emit(SignupSuccess(userModel));
    } on FirebaseAuthException catch (e) {
      emit(SignupFailure(e.message ?? 'Signup failed'));
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }
}
