import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/widgets.dart';
import 'package:ramla_school/screens/settings/data/admin_settings_cubit.dart';
import 'package:ramla_school/screens/timetable/data/admin/admin_time_table_cubit.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late TabController _tabController;

  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color deleteRed = Colors.redAccent;
  static const Color editBlue = Colors.blueAccent;
  static const Color screenBg = Color(0xFFF8F8F8);
  static Color textFieldFill = Colors.grey.shade100;
  static const Color iconGrey = Color(0xFFAAAAAA);

  List<TeacherModel> _teachers = [];
  List<StudentModel> _students = [];

  // --- State for the Add User Modal (Reset/Managed in the sheet open/close cycle) ---
  UserRole? _modalRole;
  List<Grade> _selectedGrades = [];
  Grade? _selectedGrade;
  List<SchoolSubject> _selectedSubjects = [];
  // --- End State for the Add User Modal ---

  final bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Assuming context.read<AdminTimetableCubit>() fetches these lists
    _loadTeachers();
    _loadStudents();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    // Assuming the fetch teachers logic is still correct via this cubit/service
    final cubit = context.read<AdminTimetableCubit>();
    final teachers = await cubit.fetchAllTeachers();
    setState(() => _teachers = teachers);
  }

  Future<void> _loadStudents() async {
    // Assuming the fetch students logic is still correct via this cubit/service
    final cubit = context.read<AdminTimetableCubit>();
    final students = await cubit.fetchAllStudents();
    setState(() => _students = students);
  }

  void _resetModalFields() {
    _selectedGrades.clear();
    _selectedGrade = null;
    _selectedSubjects.clear();
    _modalRole = null;
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  // ---------------- ADD USER SHEET ----------------
  void _openAddUserSheet(UserRole role) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final classNumberController = TextEditingController();

    _resetModalFields();
    _modalRole = role;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // Wrap the modal content with the listener for feedback
        return BlocListener<AdminSettingsCubit, AdminSettingsState>(
          listener: (context, state) {
            if (state is AdminSettingsSuccess) {
              // On success, refresh the lists and show message
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              _loadTeachers();
              _loadStudents();
              if (mounted) Navigator.pop(context); // Close modal
            } else if (state is AdminSettingsFailure) {
              // On failure, show error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: deleteRed,
                ),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
            ),
            child: StatefulBuilder(
              builder: (context, setModalState) {
                void setModalStateAndParent(VoidCallback fn) {
                  setModalState(fn);
                  setState(() {});
                }

                return SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          role == UserRole.teacher
                              ? 'إضافة معلمة جديدة'
                              : role == UserRole.student
                              ? 'إضافة طالبة جديدة'
                              : 'إضافة مسئولة جديدة',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --- Shared Fields ---
                        CustomTextField(
                          controller: firstNameController,
                          icon: Icons.person_outline,
                          hint: 'الاسم الأول',
                          validatorMsg: 'الرجاء إدخال الاسم الأول',
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: lastNameController,
                          icon: Icons.person_outline,
                          hint: 'اسم العائلة',
                          validatorMsg: 'الرجاء إدخال اسم العائلة',
                        ),
                        const SizedBox(height: 12),
                        CustomTextField(
                          controller: emailController,
                          icon: Icons.email_outlined,
                          hint: 'البريد الإلكتروني',
                          keyboardType: TextInputType.emailAddress,
                          validatorMsg: 'الرجاء إدخال بريد إلكتروني صحيح',
                        ),
                        const SizedBox(height: 12),

                        // --- Role-Specific Fields ---
                        if (role == UserRole.teacher) ...[
                          _buildSubjectsSelector(setModalStateAndParent),
                          const SizedBox(height: 12),
                          _buildGradesSelector(
                            setModalStateAndParent,
                          ), // multiple
                        ],

                        if (role == UserRole.student) ...[
                          _buildSingleGradeSelector(
                            setModalStateAndParent,
                          ), // single
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: classNumberController,
                            hint: 'رقم الفصل',
                            icon: Icons.class_outlined,
                            keyboardType: TextInputType.number,
                            validatorMsg: 'الرجاء إدخال رقم الفصل',
                            extraValidator: (value) {
                              final classNum = int.tryParse(value ?? '');
                              if (classNum == null || classNum < 1) {
                                return 'يجب أن يكون رقم الفصل صالحًا';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 12),

                        // --- Password Fields ---
                        CustomTextField(
                          controller: _passwordController,
                          hint: 'كلمة السر',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validatorMsg:
                              'كلمة السر يجب أن تكون 6 أحرف على الأقل',
                        ),
                        const SizedBox(height: 12),

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
                        const SizedBox(height: 20),

                        // Submit Button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon:
                              context.watch<AdminSettingsCubit>().state
                                  is AdminSettingsLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            context.watch<AdminSettingsCubit>().state
                                    is AdminSettingsLoading
                                ? 'جاري إنشاء الحساب'
                                : 'إنشاء الحساب',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          onPressed:
                              context.watch<AdminSettingsCubit>().state
                                  is AdminSettingsLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    _submitUserCreation(
                                      role: role,
                                      firstName: firstNameController.text
                                          .trim(),
                                      lastName: lastNameController.text.trim(),
                                      email: emailController.text.trim(),
                                      password: _passwordController.text.trim(),
                                      gender: Gender.female,
                                      classNumber: int.tryParse(
                                        classNumberController.text,
                                      ),
                                    );
                                  }
                                },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ).then((_) {
      _resetModalFields(); // Reset state after modal closes
    });
  }

  // ---------------- SUBMISSION LOGIC (Replaced Mock with Cubit Call) ----------------

  Future<void> _submitUserCreation({
    required UserRole role,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required Gender gender,
    int? classNumber,
  }) async {
    final cubit = context.read<AdminSettingsCubit>();

    await cubit.createNewUserAccount(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      role: role,
      gender: gender,
      subjects: role == UserRole.teacher ? _selectedSubjects : null,
      grades: role == UserRole.teacher
          ? _selectedGrades.map((g) => int.parse(g.label)).toList()
          : null,
      grade: role == UserRole.student ? int.parse(_selectedGrade!.label) : null,
      classNumber: role == UserRole.student ? classNumber : null,
    );
  }

  // ---------------- MODAL BUILDERS ----------------

  // ... (All other Modal Builders remain unchanged) ...
  InputDecoration _buildInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: iconGrey),
      filled: true,
      fillColor: textFieldFill,
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

  Widget _buildSubjectsSelector(void Function(VoidCallback) setModalState) {
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
              onTap: () => _showSubjectsDialog(setModalState),
              child: InputDecorator(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: textFieldFill,
                  hintText: 'اختر المواد التي تُدرّسها',
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
                  style: const TextStyle(fontSize: 14, color: primaryText),
                ),
              ),
            ),
            if (_selectedSubjects.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _selectedSubjects
                      .map(
                        (subject) => Chip(
                          label: Text(subject.name),
                          backgroundColor: primaryGreen.withOpacity(0.2),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setModalState(
                              () => _selectedSubjects.remove(subject),
                            );
                            formFieldState.didChange(_selectedSubjects);
                          },
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

  Widget _buildGradesSelector(void Function(VoidCallback) setModalState) {
    // Multiple grades for teachers
    return FormField<List<Grade>>(
      validator: (value) {
        if (_selectedGrades.isEmpty) {
          return 'الرجاء اختيار صف واحد على الأقل';
        }
        return null;
      },
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _showGradeSelectionSheet(setModalState),
              child: InputDecorator(
                decoration:
                    _buildInputDecoration(
                      hint: 'اختر الصفوف التي تُدرّسها',
                    ).copyWith(
                      errorText: formFieldState.errorText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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
                                backgroundColor: primaryGreen.withOpacity(0.2),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () {
                                  setModalState(
                                    () => _selectedGrades.remove(g),
                                  );
                                  formFieldState.didChange(_selectedGrades);
                                },
                              ),
                            )
                            .toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleGradeSelector(void Function(VoidCallback) setModalState) {
    // Single grade for students
    return DropdownButtonFormField<Grade>(
      initialValue: _selectedGrade,
      decoration: _buildInputDecoration(hint: 'الصف الدراسي'),
      items: Grade.values.map((grade) {
        return DropdownMenuItem(value: grade, child: Text(grade.label));
      }).toList(),
      onChanged: (value) {
        setModalState(() {
          _selectedGrade = value;
        });
      },
      validator: (value) => value == null ? 'الرجاء اختيار الصف الدراسي' : null,
    );
  }

  void _showSubjectsDialog(void Function(VoidCallback) setModalState) {
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
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'لا يمكنك اختيار أكثر من مادتين.',
                                        ),
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
                            setModalState(
                              () => _selectedSubjects = tempSelected,
                            );
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

  void _showGradeSelectionSheet(void Function(VoidCallback) setModalState) {
    final tempSelected = List<Grade>.from(_selectedGrades);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                    final isSelected = tempSelected.contains(grade);
                    return CheckboxListTile(
                      title: Text(grade.label),
                      value: isSelected,
                      onChanged: (checked) {
                        setStateDialog(() {
                          if (checked == true) {
                            if (tempSelected.length < 2) {
                              tempSelected.add(grade);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'لا يمكنك اختيار أكثر من صفين.',
                                  ),
                                ),
                              );
                            }
                          } else {
                            tempSelected.remove(grade);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      setModalState(() => _selectedGrades = tempSelected);
                      Navigator.pop(context);
                    },
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

  // ---------------- DELETE DIALOG ----------------
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String userName,
    VoidCallback onConfirm,
  ) async {
    // ... (Your original delete dialog code)
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف "$userName"؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: deleteRed),
              child: const Text('حذف'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy – hh:mm a').format(date);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(color: dividerColor, width: 0.5),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'إدارة المستخدمين',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontFamily: 'Tajawal',
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen,
          unselectedLabelColor: secondaryText,
          indicatorColor: primaryGreen,
          indicatorWeight: 3.0,
          labelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.normal,
            fontSize: 16,
          ),
          tabs: const [
            Tab(text: 'المعلمات'),
            Tab(text: 'الطالبات'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UserListSection<TeacherModel>(
            users: _teachers,
            onAdd: () => _openAddUserSheet(UserRole.teacher),
            addLabel: 'إضافة معلمة جديدة',
            itemBuilder: (teacher) => _UserCard(
              name: teacher.fullName,
              subtitle:
                  'المواد: ${teacher.subjects.map((s) => s.name).join(', ')}',
              date: _formatDate(teacher.createdAt),
              onDelete: () => _showDeleteConfirmation(
                context,
                teacher.fullName,
                () => setState(() => _teachers.remove(teacher)),
              ),
            ),
          ),
          _UserListSection<StudentModel>(
            users: _students,
            onAdd: () => _openAddUserSheet(UserRole.student),
            addLabel: 'إضافة طالبة جديدة',
            itemBuilder: (student) => _UserCard(
              name: student.fullName,
              subtitle: student.fullClassDescription,
              date: _formatDate(student.createdAt),
              onDelete: () => _showDeleteConfirmation(
                context,
                student.fullName,
                () => setState(() => _students.remove(student)),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddUserSheet(UserRole.admin),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.admin_panel_settings_outlined),
        label: const Text(
          'إضافة مسئولة',
          style: TextStyle(fontFamily: 'Tajawal'),
        ),
      ),
    );
  }
}

// ---------------- LIST SECTION ----------------
class _UserListSection<T> extends StatelessWidget {
  final List<T> users;
  final VoidCallback onAdd;
  final String addLabel;
  final Widget Function(T user) itemBuilder;

  const _UserListSection({
    required this.users,
    required this.onAdd,
    required this.addLabel,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline),
            label: Text(
              addLabel,
              style: const TextStyle(fontFamily: 'Tajawal'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _AdminSettingsScreenState.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? const Center(
                  child: Text(
                    'لا يوجد مستخدمات حالياً',
                    style: TextStyle(
                      color: _AdminSettingsScreenState.secondaryText,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: users.length,
                  itemBuilder: (context, i) => itemBuilder(users[i]),
                  separatorBuilder: (context, i) => const SizedBox(height: 12),
                ),
        ),
      ],
    );
  }
}

// ---------------- USER CARD ----------------
class _UserCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String date;
  final VoidCallback onDelete;

  const _UserCard({
    required this.name,
    required this.subtitle,
    required this.date,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: _AdminSettingsScreenState.primaryGreen,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: _AdminSettingsScreenState.secondaryText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Tajawal',
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: _AdminSettingsScreenState.deleteRed,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
