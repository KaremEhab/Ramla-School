import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ramla_school/core/models/users/user_model.dart';
import 'package:ramla_school/core/services/cache_helper.dart';
import 'package:ramla_school/screens/auth/presentation/login.dart';
import 'package:ramla_school/screens/layout.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _firestore = FirebaseFirestore.instance;
  bool? _isLoggedIn; // هنا نخزن النتيجة

  @override
  void initState() {
    super.initState();
    _initSplash();
  }

  void _initSplash() async {
    final result = await _checkUserStatus();
    if (mounted) {
      setState(() {
        _isLoggedIn = result;
      });
    }
  }

  Future<bool> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (currentUser == null || currentRole == null) return false;

    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.id)
          .get();

      if (userDoc.exists) {
        final newData = userDoc.data()!;
        if (newData.toString() != currentUser!.toMap().toString()) {
          currentUser = currentUser!.copyWithJson(newData);
          await CacheHelper.cacheUserData(currentUser!, currentRole!.name);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    const Color colorTop = Color(0xFFACD5C3);
    const Color colorBottom = Colors.white;
    const Color primaryColor = Color(0xFF005A4D);
    const Color accentColor = Color(0xFFF39C12);

    // لو النتيجة لسه null، نعرض Splash
    if (_isLoggedIn == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [colorTop, colorBottom],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/ramla-logo.png', width: 230),
                const SizedBox(height: 44),
                const SizedBox(
                  width: 270,
                  child: Text(
                    'مدرسة رملة أم المؤمنين ترحب بكم!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: LoadingAnimationWidget.progressiveDots(
                    color: accentColor,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      );
    }

    // بعد ما النتيجة جاهزة نروح للشاشة المناسبة
    return _isLoggedIn! ? const LayoutScreen() : const Login();
  }
}
