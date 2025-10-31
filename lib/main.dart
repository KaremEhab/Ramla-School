import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/services/cache_helper.dart';
import 'package:ramla_school/screens/auth/data/login/login_cubit.dart';
import 'package:ramla_school/screens/auth/data/signup/signup_cubit.dart';
import 'package:ramla_school/screens/layout.dart';
import 'package:ramla_school/screens/splash.dart';

import 'firebase_options.dart'; // Make sure this path is correct

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ar');
  await CacheHelper.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // This ensures your app layout is always Right-to-Left
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SignupCubit()),
        BlocProvider(create: (_) => LoginCubit()),
      ],
      child: MaterialApp(
        title: 'مدرسة رملة', // You can use Arabic here
        debugShowCheckedModeBanner: false,

        // --- Configuration for Arabic Language ---
        locale: const Locale('ar'), // Force Arabic locale
        supportedLocales: const [
          Locale('ar'), // Only support Arabic
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // ----------------------------------------
        theme: ThemeData(
          fontFamily: 'Tajawal',
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),

          // Optional: This can make text look more natural in Arabic
          textTheme: const TextTheme(
            bodyMedium: TextStyle(height: 1.5), // Adds a bit of line spacing
            bodyLarge: TextStyle(height: 1.5),
          ),
        ),

        // home: const LayoutScreen(),
        home: const SplashScreen(),
      ),
    );
  }
}
