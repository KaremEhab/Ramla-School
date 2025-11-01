import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/user_model.dart';
import 'package:ramla_school/core/services/cache_helper.dart';
import 'package:ramla_school/screens/analytics/data/admin_analytics_cubit.dart';
import 'package:ramla_school/screens/auth/data/login/login_cubit.dart';
import 'package:ramla_school/screens/auth/data/signup/signup_cubit.dart';
import 'package:ramla_school/screens/home/data/user_cubit.dart';
import 'package:ramla_school/screens/settings/data/admin_settings_cubit.dart';
import 'package:ramla_school/screens/splash.dart';
import 'package:ramla_school/screens/timetable/data/admin/admin_time_table_cubit.dart';
import 'package:ramla_school/screens/timetable/data/student/student_time_table_cubit.dart';
import 'package:ramla_school/screens/timetable/data/teacher/teacher_time_table_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ar');
  await CacheHelper.init();

  // Load cached user and role before running the app
  final cachedUser = await CacheHelper.getData(key: 'currentUser');
  final cachedRole = await CacheHelper.getData(key: 'currentRole');

  if (cachedUser != null && cachedRole != null) {
    try {
      final cachedUser = await CacheHelper.getData(key: 'currentUser');
      if (cachedUser != null) {
        final decodedUser = jsonDecode(cachedUser); // ✅ decode before using
        currentUser = UserModel.fromMap(Map<String, dynamic>.from(decodedUser));
      }
      currentRole = userRoleFromString(cachedRole); // ✅ restore role in memory
      log(
        '✅ Cached user restored: ${currentUser?.fullName} (${currentRole?.name})',
      );
    } catch (e) {
      log('❌ Error loading cached user: $e');
      await CacheHelper.removeData(key: 'currentUser');
      await CacheHelper.removeData(key: 'currentRole');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SignupCubit()),
        BlocProvider(create: (_) => LoginCubit()),
        BlocProvider(create: (_) => UserCubit()),
        BlocProvider(create: (_) => AdminAnalyticsCubit()),
        BlocProvider(create: (_) => AdminSettingsCubit()),
        BlocProvider(create: (_) => AdminTimetableCubit()),
        BlocProvider(create: (_) => TeacherTimetableCubit()),
        BlocProvider(create: (_) => StudentTimetableCubit()),
      ],
      child: MaterialApp(
        title: 'مدرسة رملة',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          fontFamily: 'Tajawal',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(height: 1.5),
            bodyLarge: TextStyle(height: 1.5),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
