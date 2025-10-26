import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/services/cache_helper.dart';
import 'package:ramla_school/core/utils.dart';
import 'package:ramla_school/screens/auth/presentation/signup.dart';
import 'package:ramla_school/screens/home/presentation/home.dart';
import 'package:ramla_school/screens/layout.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Colors based on your design
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color accentOrange = Color(0xFFF39C12);
  static const Color textFieldFill = Color(0xFFF9F9F9);
  static const Color iconGrey = Color(0xFFAAAAAA);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1. Top-Right Green Ornament
            // This will appear on the top-right in RTL
            Positioned(
              top: 0,
              right: 0, // In RTL, 'left: 0' is the right side of the screen
              child: ClipPath(
                clipper: CircleClipper(),
                child: Container(
                  width: 200,
                  height: 140,
                  color: primaryGreen.withOpacity(0.8),
                ),
              ),
            ),

            // 2. Main Login Form
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80),

                          // 3. Logo
                          Center(
                            child: Image.asset(
                              'assets/images/ramla-logo.png',
                              height: 200,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 4. Title
                          const Text(
                            'تسجيل دخول',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 5. Subtitle
                          const Text(
                            'يرجى تسجيل الدخول للمواصلة.',
                            style: TextStyle(
                              fontSize: 16,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 6. Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _buildInputDecoration(
                              hint: 'البريد الالكتروني',
                              icon: Icons.email_outlined,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  !value.contains('@')) {
                                return 'الرجاء إدخال بريد إلكتروني صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 7. Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isPasswordObscured,
                            decoration: _buildInputDecoration(
                              hint: 'كلمة السر',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.length < 6) {
                                return 'كلمة السر يجب أن تكون 6 أحرف على الأقل';
                              }
                              return null;
                            },
                          ),

                          // 8. Forgot Password
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Handle forgot password
                              },
                              child: const Text(
                                'هل نسيت كلمة السر؟',
                                style: TextStyle(
                                  color: accentOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 9. Login Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'تسجيل الدخول',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 10. Signup Link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Tajawal',
                                  color: secondaryText,
                                ),
                                children: [
                                  const TextSpan(text: 'ليس لديك حساب؟ '),
                                  TextSpan(
                                    text: 'انشاء حساب جديد',
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const Signup(),
                                          ),
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      String email = _emailController.text;
      String password = _passwordController.text;

      // TODO: Add your Firebase/Cubit login logic here
      print('Logging in with Email: $email, Password: $password');

      currentRole = UserRole.student;
      await CacheHelper.saveData(key: 'currentRole', value: currentRole!.name);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LayoutScreen()),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: iconGrey),
      filled: true,
      fillColor: textFieldFill,
      prefixIcon: Icon(icon, color: iconGrey),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                _isPasswordObscured
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: iconGrey,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGreen),
      ),
    );
  }
}
