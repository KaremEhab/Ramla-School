import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/services/cache_helper.dart';
import 'package:ramla_school/core/utils.dart';
import 'package:ramla_school/screens/home/presentation/home.dart';
import 'package:ramla_school/screens/layout.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  UserRole? _selectedRole;
  final List<UserRole> _roles = [UserRole.student, UserRole.teacher];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Colors based on your design
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
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

            // 2. Main Signup Form
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
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: primaryGreen,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 60),

                          // 3. Title
                          const Text(
                            'انشاء حساب جديد',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 4. First Name Field
                          TextFormField(
                            controller: _firstNameController,
                            decoration: _buildInputDecoration(
                              hint: 'اسمك',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال اسمك بشكل صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 4. Last Name Field
                          TextFormField(
                            controller: _lastNameController,
                            decoration: _buildInputDecoration(
                              hint: 'اسم العائلة',
                              icon: Icons.person_outline,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال اسم العائلة بشكل صحيح';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 5. Email Field
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

                          // 6. Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _isPasswordObscured,
                            decoration: _buildInputDecoration(
                              hint: 'كلمة السر',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              isConfirm: false,
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
                          const SizedBox(height: 20),

                          // 7. Confirm Password Field
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _isConfirmPasswordObscured,
                            decoration: _buildInputDecoration(
                              hint: 'تأكيد كلمة السر',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              isConfirm: true,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء تأكيد كلمة السر';
                              }
                              if (value != _passwordController.text) {
                                return 'كلمتا السر غير متطابقتين';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // 8. Role Dropdown
                          DropdownButtonFormField<UserRole>(
                            value: _selectedRole,
                            hint: const Text(
                              'طالبة / أستاذة',
                              style: TextStyle(color: iconGrey),
                            ),
                            decoration: _buildInputDecoration(
                              icon: Icons.keyboard_arrow_down_outlined,
                              isDropdown: true,
                            ),
                            items: _roles.map((UserRole role) {
                              return DropdownMenuItem<UserRole>(
                                value: role,
                                child: Text(getRoleNameInArabic(role)),
                              );
                            }).toList(),

                            onChanged: (newValue) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'الرجاء اختيار دورك';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // 9. Signup Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _signup,
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
                                'انشاء حساب جديد',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // 10. Login Link
                          Center(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Tajawal',
                                  color: secondaryText,
                                ),
                                children: [
                                  const TextSpan(text: ' لديك حساب؟ '),
                                  TextSpan(
                                    text: 'تسجيل دخول',
                                    style: const TextStyle(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate back to Login Screen
                                        if (Navigator.of(context).canPop()) {
                                          Navigator.of(context).pop();
                                        }
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

  Future<void> _signup() async {
    currentRole = _selectedRole!;
    await CacheHelper.saveData(key: 'currentRole', value: currentRole!.name);

    if (_formKey.currentState!.validate()) {
      // Form is valid
      String firstName = _firstNameController.text;
      String lastName = _lastNameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      UserRole role = _selectedRole!;

      // TODO: Add your Firebase/Cubit signup logic here
      print(
        'Signing up with First name: $firstName, Last name: $lastName, Email: $email, Password: $password, Role: ${role.name}',
      );

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LayoutScreen()),
      );
    }
  }

  InputDecoration _buildInputDecoration({
    String? hint,
    required IconData icon,
    bool isPassword = false,
    bool isConfirm = false,
    bool isDropdown = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: iconGrey),
      filled: true,
      fillColor: textFieldFill,
      // Use prefixIcon for all fields except dropdown
      prefixIcon: isDropdown ? null : Icon(icon, color: iconGrey),
      // Use suffixIcon for password toggle AND dropdown icon
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                (isConfirm ? _isConfirmPasswordObscured : _isPasswordObscured)
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: iconGrey,
              ),
              onPressed: () {
                setState(() {
                  if (isConfirm) {
                    _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                  } else {
                    _isPasswordObscured = !_isPasswordObscured;
                  }
                });
              },
            )
          : (isDropdown
                ? Icon(icon, color: iconGrey) // Dropdown arrow
                : null),
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
