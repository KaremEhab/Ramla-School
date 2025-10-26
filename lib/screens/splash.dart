import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ramla_school/screens/auth/presentation/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 5 seconds, then navigate to Login screen
    Future.delayed(const Duration(seconds: 5), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Colors for the gradient
    const Color colorTop = Color(0xFFACD5C3);
    const Color colorBottom = Colors.white;

    // This color is sampled from the text and logo
    const Color primaryColor = Color(0xFF005A4D);

    // This color is sampled from the dots
    const Color accentColor = Color(0xFFF39C12);

    return Scaffold(
      // We no longer set a single backgroundColor on the Scaffold
      body: Container(
        // Apply the gradient decoration
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [colorTop, colorBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SizedBox(
          // Use double.infinity to center the Column horizontally
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            // Center the content horizontally
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. The Logo
              Image.asset(
                'assets/images/ramla-logo.png',
                width: 230, // You can adjust the size
              ),

              const SizedBox(height: 44),

              // 2. The Welcome Text
              SizedBox(
                width: 270,
                child: const Text(
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

              // 3. The Animated Jumping Dots
              Directionality(
                textDirection: TextDirection.ltr,
                child: LoadingAnimationWidget.progressiveDots(
                  color: accentColor,
                  size: 60,
                ),
              ),

              // Padding from the bottom of the screen
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
