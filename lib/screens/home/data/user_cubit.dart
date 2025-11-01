import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/user_model.dart';
import 'package:ramla_school/core/services/cache_helper.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final FirebaseFirestore _firestore;

  UserCubit({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(UserInitial());

  Stream<UserModel> listenToUser(String userId) {
    log('👂 Listening to user changes: $userId');

    return _firestore.collection('users').doc(userId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) throw Exception("User document not found!");
      final data = snapshot.data()!;
      final user = UserModel.fromMap(data);

      // تحديث الـ currentUser والـ Cache
      currentUser = user;
      currentRole = user.role;
      CacheHelper.saveData(key: 'currentUser', value: data);
      CacheHelper.saveData(key: 'currentRole', value: user.role.name);

      emit(UserUpdated(user));
      return user;
    });
  }
}
