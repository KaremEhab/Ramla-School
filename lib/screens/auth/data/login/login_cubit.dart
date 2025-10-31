import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  LoginCubit({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance,
      super(LoginInitial());

  Future<void> login({required String email, required String password}) async {
    emit(LoginLoading());
    try {
      // 1️⃣ Sign in using Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // 2️⃣ Fetch user data from Firestore
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        emit(LoginFailure('User data not found.'));
        return;
      }

      final userModel = UserModel.fromMap(userDoc.data()!);

      emit(LoginSuccess(userModel));
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.message ?? 'Login failed'));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    emit(LoginInitial());
  }
}
