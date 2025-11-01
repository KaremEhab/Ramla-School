import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/user_model.dart';
import 'package:ramla_school/core/services/cache_helper.dart';

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
      // 1️⃣ Login via Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user!.uid;

      // 2️⃣ Try to fetch from "admins" first
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('admins')
          .doc(uid)
          .get();

      // 3️⃣ If not found in "admins", fetch from "users"
      if (!doc.exists) {
        doc = await _firestore.collection('users').doc(uid).get();

        if (!doc.exists) {
          emit(LoginFailure('لم يتم العثور على بيانات المستخدم.'));
          return;
        }
      }

      // 4️⃣ Convert to UserModel
      final user = UserModel.fromMap(doc.data()!);

      // 5️⃣ Save locally (optional, if you're caching)
      currentUser = user;
      currentRole = user.role;
      CacheHelper.saveData(key: "currentUser", value: user.toMap());
      CacheHelper.saveData(key: "currentRole", value: user.role.name);

      emit(LoginSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(LoginFailure(e.message ?? 'حدث خطأ أثناء تسجيل الدخول.'));
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    currentUser = null;
    currentRole = null;
    CacheHelper.removeData(key: "currentUser");
    CacheHelper.removeData(key: "currentRole");
    await _auth.signOut();
    emit(LoginInitial());
  }
}
