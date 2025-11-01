import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/services/cache_helper.dart';
import 'package:ramla_school/core/utils.dart';
import 'package:ramla_school/screens/auth/data/signup/signup_cubit.dart';
import 'package:ramla_school/screens/auth/data/signup/signup_cubit.dart';
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
  final _gradeController = TextEditingController();
  final _classNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;
  UserRole? _selectedRole;
  final List<Grade> _selectedGrades = [];
  List<SchoolSubject> _selectedSubjects = [];
  final List<UserRole> _roles = [
    UserRole.admin,
    UserRole.student,
    UserRole.teacher,
  ];

  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color textFieldFill = Color(0xFFF9F9F9);
  static const Color iconGrey = Color(0xFFAAAAAA);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _gradeController.dispose();
    _classNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) async {
        if (state is SignupLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.all(24),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('جاري إنشاء الحساب...', style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        } else {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is SignupSuccess) {
          // ✅ Save user and role locally
          currentUser = state.user;
          currentRole = state.user.role;

          await CacheHelper.saveData(
            key: 'currentRole',
            value: state.user.role.name,
          );
          await CacheHelper.saveData(
            key: 'currentUser',
            value: state.user.toMap(),
          );

          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم إنشاء الحساب بنجاح')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LayoutScreen()),
          );
        } else if (state is SignupFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: CircleClipper(),
                    child: Container(
                      width: 200,
                      height: 140,
                      color: primaryGreen.withOpacity(0.8),
                    ),
                  ),
                ),
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
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              const Text(
                                'انشاء حساب جديد',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                ),
                              ),
                              const SizedBox(height: 32),
                              TextFormField(
                                controller: _firstNameController,
                                decoration: _buildInputDecoration(
                                  hint: 'اسمك',
                                  icon: Icons.person_outline,
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'الرجاء إدخال اسمك بشكل صحيح'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: _buildInputDecoration(
                                  hint: 'اسم العائلة',
                                  icon: Icons.person_outline,
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty
                                    ? 'الرجاء إدخال اسم العائلة بشكل صحيح'
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _buildInputDecoration(
                                  hint: 'البريد الالكتروني',
                                  icon: Icons.email_outlined,
                                ),
                                validator: (value) =>
                                    value == null || !value.contains('@')
                                    ? 'الرجاء إدخال بريد إلكتروني صحيح'
                                    : null,
                              ),
                              const SizedBox(height: 20),

                              // Role Dropdown
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
                                    _selectedSubjects = [];
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'الرجاء اختيار دورك' : null,
                              ),
                              if (_selectedRole == UserRole.teacher)
                                const SizedBox(height: 20),

                              // Subjects Selector
                              if (_selectedRole == UserRole.teacher)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    FormField<List<SchoolSubject>>(
                                      validator: (value) {
                                        if (_selectedSubjects.isEmpty) {
                                          return 'الرجاء اختيار مادة واحدة على الأقل';
                                        }
                                        return null;
                                      },
                                      builder: (formFieldState) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: _showSubjectsDialog,
                                              child: InputDecorator(
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: textFieldFill,
                                                  prefixIcon: const Icon(
                                                    Icons.school,
                                                    color: iconGrey,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderSide: BorderSide.none,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  errorText: formFieldState
                                                      .errorText, // show validator message
                                                ),
                                                child: Text(
                                                  _selectedSubjects.isEmpty
                                                      ? 'اختر المواد التي تُدرّسها'
                                                      : _selectedSubjects
                                                            .map((s) => s.name)
                                                            .join('، '),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    if (_selectedSubjects.isNotEmpty)
                                      const SizedBox(height: 10),

                                    // Scrollable row for selected subjects
                                    if (_selectedSubjects.isNotEmpty)
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: _selectedSubjects
                                              .map(
                                                (subject) => Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                      ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: primaryGreen
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        subject.name,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: primaryText,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            _selectedSubjects
                                                                .remove(
                                                                  subject,
                                                                );
                                                          });
                                                        },
                                                        child: const Icon(
                                                          Icons.close,
                                                          size: 18,
                                                          color: iconGrey,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                  ],
                                ),

                              if (_selectedRole != null &&
                                  _selectedRole != UserRole.admin)
                                const SizedBox(height: 20),

                              // Grade field
                              if (_selectedRole != null &&
                                  _selectedRole != UserRole.admin)
                                GestureDetector(
                                  onTap: () => _showGradeSelectionSheet(),
                                  child: InputDecorator(
                                    decoration: _buildInputDecoration(
                                      hint: 'الصف الدراسي',
                                      icon: Icons.numbers,
                                    ),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: _selectedGrades.isEmpty
                                          ? [Text('اختر صفًا واحدًا على الأقل')]
                                          : _selectedGrades
                                                .map(
                                                  (g) => Chip(
                                                    label: Text(g.label),
                                                    onDeleted: () {
                                                      setState(() {
                                                        _selectedGrades.remove(
                                                          g,
                                                        );
                                                      });
                                                    },
                                                  ),
                                                )
                                                .toList(),
                                    ),
                                  ),
                                ),

                              if (_selectedRole == UserRole.student)
                                const SizedBox(height: 20),

                              // Class number (for student only)
                              if (_selectedRole == UserRole.student)
                                TextFormField(
                                  controller: _classNumberController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(
                                    hint: 'الفصل الدراسي',
                                    icon: Icons.class_,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'الرجاء اختيار الفصل الدراسي';
                                    }
                                    final classNum = int.tryParse(value);
                                    if (classNum == null ||
                                        classNum < 1 ||
                                        classNum > 9) {
                                      return 'يجب أن يكون رقم الفصل بين 1 و 9';
                                    }
                                    return null;
                                  },
                                ),
                              const SizedBox(height: 20),

                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _isPasswordObscured,
                                decoration: _buildInputDecoration(
                                  hint: 'كلمة السر',
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                ),
                                validator: (value) =>
                                    value == null || value.length < 6
                                    ? 'كلمة السر يجب أن تكون 6 أحرف على الأقل'
                                    : null,
                              ),
                              const SizedBox(height: 20),

                              // Confirm password
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
                              const SizedBox(height: 32),

                              // Signup button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state is SignupLoading
                                      ? null
                                      : _signup,
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
                                  child: Text(
                                    state is SignupLoading
                                        ? 'يتم الآن انشاء حسابك'
                                        : 'إنشاء حساب جديد',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Login link
                              Center(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
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
                                            if (Navigator.of(
                                              context,
                                            ).canPop()) {
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
      },
    );
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
      prefixIcon: isDropdown ? null : Icon(icon, color: iconGrey),
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
          : (isDropdown ? Icon(icon, color: iconGrey) : null),
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

  void _showSubjectsDialog() {
    final tempSelected = List<SchoolSubject>.from(_selectedSubjects);
    final allSubjects = SchoolSubject.values;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اختر المواد الدراسية',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Scrollable list of subjects
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: allSubjects.map((subject) {
                          final isSelected = tempSelected.contains(subject);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(subject.name),
                            activeColor: primaryGreen,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (selected) {
                              setStateDialog(() {
                                if (selected == true) {
                                  if (tempSelected.length < 2) {
                                    tempSelected.add(subject);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'يمكنك اختيار مادتين فقط، احذف واحدة أولاً',
                                        ),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                } else {
                                  tempSelected.remove(subject);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSubjects = tempSelected;
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('تم'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) return;

    if (_selectedGrades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صف واحد على الأقل')),
      );
      return;
    }

    final cubit = context.read<SignupCubit>();

    cubit.signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole!,
      subjects: _selectedRole == UserRole.teacher ? _selectedSubjects : null,
      grade: _selectedRole == UserRole.student
          ? int.tryParse(_gradeController.text)
          : null,
      grades: _selectedGrades.map((g) => g.index).toList(),
      classNumber: _selectedRole == UserRole.student
          ? int.tryParse(_classNumberController.text)
          : null,
    );
  }

  void _showGradeSelectionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'اختر الصفوف (بحد أقصى صفين)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ...Grade.values.map((grade) {
                    final isSelected = _selectedGrades.contains(grade);
                    return CheckboxListTile(
                      title: Text(grade.label),
                      value: isSelected,
                      onChanged: (checked) {
                        setModalState(() {
                          if (checked == true) {
                            if (_selectedGrades.length < 2) {
                              _selectedGrades.add(grade);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('يمكنك اختيار صفين فقط'),
                                ),
                              );
                            }
                          } else {
                            _selectedGrades.remove(grade);
                          }
                        });
                        setState(() {}); // update parent UI
                      },
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('تم'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
