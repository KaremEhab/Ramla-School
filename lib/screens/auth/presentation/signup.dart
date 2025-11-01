import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/services/cache_helper.dart';
import 'package:ramla_school/core/utils.dart';
import 'package:ramla_school/core/widgets.dart';
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

  // For teachers (multiple grades)
  final List<Grade> _selectedGrades = [];
  // For students (single grade)
  Grade? _selectedGrade;

  List<SchoolSubject> _selectedSubjects = [];
  final List<UserRole> _roles = [
    UserRole.admin,
    UserRole.student,
    UserRole.teacher,
  ];

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
            backgroundColor: screenBg,
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
                      color: primaryGreen.withAlpha((0.8 * 255).round()),
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
                                      backgroundColor: screenBg,
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
                              CustomTextField(
                                controller: _firstNameController,
                                hint: 'اسمك',
                                icon: Icons.person_outline,
                                validatorMsg: 'الرجاء إدخال اسمك بشكل صحيح',
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: _lastNameController,
                                hint: 'اسم العائلة',
                                icon: Icons.person_outline,
                                validatorMsg:
                                    'الرجاء إدخال اسم العائلة بشكل صحيح',
                              ),
                              const SizedBox(height: 20),
                              CustomTextField(
                                controller: _emailController,
                                hint: 'البريد الالكتروني',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validatorMsg: 'الرجاء إدخال بريد إلكتروني صحيح',
                              ),
                              const SizedBox(height: 20),

                              // Role Dropdown
                              DropdownButtonFormField<UserRole>(
                                initialValue: _selectedRole,
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
                                    _selectedGrades.clear();
                                    _selectedGrade = null;
                                  });
                                },
                                validator: (value) =>
                                    value == null ? 'الرجاء اختيار دورك' : null,
                              ),
                              const SizedBox(height: 20),

                              // Subjects Selector (teachers only)
                              if (_selectedRole == UserRole.teacher)
                                _buildSubjectsSelector(),

                              if (_selectedRole == UserRole.teacher)
                                const SizedBox(height: 20),

                              // Grades Selector
                              if (_selectedRole == UserRole.teacher)
                                _buildGradesSelector(), // multiple
                              if (_selectedRole == UserRole.student)
                                _buildSingleGradeSelector(), // single

                              const SizedBox(height: 20),

                              // Class number (students only)
                              if (_selectedRole == UserRole.student)
                                CustomTextField(
                                  controller: _classNumberController,
                                  hint: 'الفصل الدراسي',
                                  icon: Icons.class_,
                                  keyboardType: TextInputType.number,
                                  validatorMsg: 'الرجاء اختيار الفصل الدراسي',
                                  extraValidator: (value) {
                                    final classNum = int.tryParse(value ?? '');
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
                              CustomTextField(
                                controller: _passwordController,
                                hint: 'كلمة السر',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                validatorMsg:
                                    'كلمة السر يجب أن تكون 6 أحرف على الأقل',
                              ),
                              const SizedBox(height: 20),

                              // Confirm Password
                              CustomTextField(
                                controller: _confirmPasswordController,
                                hint: 'تأكيد كلمة السر',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                isConfirm: true,
                                validatorMsg: 'الرجاء تأكيد كلمة السر',
                                extraValidator: (value) {
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
                                    foregroundColor: screenBg,
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
                                    style: const TextStyle(
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

  Widget _buildSubjectsSelector() {
    return FormField<List<SchoolSubject>>(
      validator: (value) {
        if (_selectedSubjects.isEmpty) {
          return 'الرجاء اختيار مادة واحدة على الأقل';
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: _showSubjectsDialog,
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: textFieldFill,
                  prefixIcon: const Icon(Icons.school, color: iconGrey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorText: formFieldState.errorText,
                ),
                child: Text(
                  _selectedSubjects.isEmpty
                      ? 'اختر المواد التي تُدرّسها'
                      : _selectedSubjects.map((s) => s.name).join('، '),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            if (_selectedSubjects.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _selectedSubjects
                      .map(
                        (subject) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(20),
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
                                  setState(
                                    () => _selectedSubjects.remove(subject),
                                  );
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
        );
      },
    );
  }

  Widget _buildGradesSelector() {
    // Multiple grades for teachers
    return GestureDetector(
      onTap: _showGradeSelectionSheet,
      child: InputDecorator(
        decoration: _buildInputDecoration(
          hint: 'اختر الصفوف',
          icon: Icons.numbers,
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _selectedGrades.isEmpty
              ? [const Text('اختر صفًا واحدًا على الأقل')]
              : _selectedGrades
                    .map(
                      (g) => Chip(
                        label: Text(g.label),
                        onDeleted: () =>
                            setState(() => _selectedGrades.remove(g)),
                      ),
                    )
                    .toList(),
        ),
      ),
    );
  }

  Widget _buildSingleGradeSelector() {
    // Single grade for students
    return DropdownButtonFormField<Grade>(
      initialValue: _selectedGrade,
      decoration: _buildInputDecoration(
        hint: 'الصف الدراسي',
        icon: Icons.numbers,
        isDropdown: true,
      ),
      items: Grade.values.map((grade) {
        return DropdownMenuItem(value: grade, child: Text(grade.label));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedGrade = value;
        });
      },
      validator: (value) => value == null ? 'الرجاء اختيار الصف الدراسي' : null,
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) return;

    final cubit = context.read<SignupCubit>();

    cubit.signup(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole!,
      subjects: _selectedRole == UserRole.teacher ? _selectedSubjects : null,
      grades: _selectedRole == UserRole.teacher
          ? _selectedGrades.map((g) => int.parse(g.label)).toList()
          : null,
      grade: _selectedRole == UserRole.student
          ? int.parse(_selectedGrade!.label)
          : null,
      classNumber: _selectedRole == UserRole.student
          ? int.tryParse(_classNumberController.text)
          : null,
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
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedSubjects = tempSelected);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: screenBg,
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
                            }
                          } else {
                            _selectedGrades.remove(grade);
                          }
                        });
                        setState(() {});
                      },
                    );
                  }),
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
