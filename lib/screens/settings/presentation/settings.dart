import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/admin_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color deleteRed = Colors.redAccent;
  static const Color editBlue = Colors.blueAccent;
  static const Color screenBg = Color(0xFFF8F8F8);

  List<TeacherModel> _teachers = [];
  List<StudentModel> _students = [];
  List<AdminModel> _admins = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMockData();
  }

  void _generateMockData() {
    _teachers = [
      TeacherModel(
        id: 't1',
        firstName: 'أحمد',
        lastName: 'الشيخ',
        email: 'teacher1@example.com',
        imageUrl: 'https://placehold.co/80x80/A0D9A4/333333?text=T1',
        status: UserStatus.online,
        gender: Gender.male,
        grades: [6],
        createdAt: DateTime.now(),
        subjects: [SchoolSubject.math],
      ),
    ];

    _students = [
      StudentModel(
        id: 's1',
        firstName: 'منى',
        lastName: 'محمد',
        email: 'student1@example.com',
        imageUrl: 'https://placehold.co/80x80/FFDDC1/333333?text=S1',
        status: UserStatus.offline,
        gender: Gender.female,
        createdAt: DateTime.now(),
        grade: 9,
        classNumber: 2,
      ),
    ];

    _admins = [
      AdminModel(
        id: 'a1',
        firstName: 'كريم',
        lastName: 'إيهاب',
        email: 'admin@example.com',
        imageUrl: '',
        status: UserStatus.online,
        gender: Gender.male,
        createdAt: DateTime.now(),
      ),
    ];
  }

  // ---------------- ADD USER SHEET ----------------
  void _openAddUserSheet(UserRole role) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final gender = ValueNotifier<Gender>(Gender.male);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      role == UserRole.teacher
                          ? 'إضافة معلم جديد'
                          : role == UserRole.student
                          ? 'إضافة طالب جديد'
                          : 'إضافة مسؤول جديد',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'الاسم الأول',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم العائلة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder(
                      valueListenable: gender,
                      builder: (context, g, _) {
                        return DropdownButtonFormField<Gender>(
                          initialValue: g,
                          decoration: const InputDecoration(
                            labelText: 'النوع',
                            border: OutlineInputBorder(),
                          ),
                          items: Gender.values.map((gen) {
                            return DropdownMenuItem(
                              value: gen,
                              child: Text(gen.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) => gender.value = val!,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      onPressed: () {
                        final id = Random().nextInt(1000).toString();
                        final now = DateTime.now();

                        setState(() {
                          if (role == UserRole.teacher) {
                            _teachers.add(
                              TeacherModel(
                                id: id,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                imageUrl: '',
                                status: UserStatus.online,
                                gender: gender.value,
                                grades: [6],
                                createdAt: now,
                                subjects: [SchoolSubject.math],
                              ),
                            );
                          } else if (role == UserRole.student) {
                            _students.add(
                              StudentModel(
                                id: id,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                imageUrl: '',
                                status: UserStatus.online,
                                gender: gender.value,
                                createdAt: now,
                                grade: 10,
                                classNumber: 2,
                              ),
                            );
                          } else {
                            _admins.add(
                              AdminModel(
                                id: id,
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                imageUrl: '',
                                status: UserStatus.online,
                                gender: gender.value,
                                createdAt: now,
                              ),
                            );
                          }
                        });

                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
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
            Tab(text: 'المعلمين'),
            Tab(text: 'الطلاب'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UserListSection<TeacherModel>(
            users: _teachers,
            onAdd: () => _openAddUserSheet(UserRole.teacher),
            addLabel: 'إضافة معلم جديد',
            itemBuilder: (teacher) => _UserCard(
              name: teacher.fullName,
              subtitle: teacher.email,
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
            addLabel: 'إضافة طالب جديد',
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
          'إضافة مسؤول',
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
                    'لا يوجد مستخدمون حالياً',
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
