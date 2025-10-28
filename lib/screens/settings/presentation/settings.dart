import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color iconGrey = Color(0xFFAAAAAA);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color deleteRed = Colors.redAccent;
  static const Color editBlue = Colors.blueAccent;
  static const Color screenBg = Color(0xFFF8F8F8);

  // --- Mock Data ---
  late List<TeacherModel> _teachers;
  late List<StudentModel> _students;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMockData();
  }

  void _generateMockData() {
    _teachers = List.generate(
      5,
      (index) => TeacherModel(
        id: 't${index + 1}',
        firstName: 'معلمة',
        lastName: '${index + 1}',
        email: 'teacher${index + 1}@example.com',
        imageUrl:
            'https://placehold.co/80x80/A0D9A4/333333?text=T${index + 1}',
        status: UserStatus.offline,
        gender: Gender.female,
        createdAt: DateTime.now().subtract(Duration(days: index * 10)),
        // ✅ Fixed: use SchoolSubject not LessonModel
        subjects: [
          SchoolSubject.values[index % SchoolSubject.values.length],
        ],
      ),
    );

    _students = List.generate(
      8,
      (index) => StudentModel(
        id: 's${index + 1}',
        firstName: 'طالبة',
        lastName: '${index + 1}',
        email: 'student${index + 1}@example.com',
        imageUrl:
            'https://placehold.co/80x80/FFDDC1/333333?text=S${index + 1}',
        status: UserStatus.offline,
        gender: Gender.female,
        createdAt: DateTime.now().subtract(Duration(days: index * 5)),
        grade: 6 + (index % 4),
        classNumber: (index % 3) + 1,
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Action Handlers ---
  void _addTeacher() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Add Teacher Form')),
    );
  }

  void _editTeacher(TeacherModel teacher) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to Edit Teacher: ${teacher.fullName}')),
    );
  }

  void _deleteTeacher(TeacherModel teacher) {
    _showDeleteConfirmation(context, teacher.fullName, () {
      setState(() {
        _teachers.removeWhere((t) => t.id == teacher.id);
      });
    });
  }

  void _addStudent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Add Student Form')),
    );
  }

  void _editStudent(StudentModel student) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to Edit Student: ${student.fullName}')),
    );
  }

  void _deleteStudent(StudentModel student) {
    _showDeleteConfirmation(context, student.fullName, () {
      setState(() {
        _students.removeWhere((s) => s.id == student.id);
      });
    });
  }

  void _addAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Add Admin Form')),
    );
  }

  // --- Delete Confirmation Dialog ---
  Future<void> _showDeleteConfirmation(
      BuildContext context, String userName, VoidCallback onConfirm) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('هل أنت متأكد من رغبتك في حذف المستخدم "$userName"؟'),
                const Text(
                  'لا يمكن التراجع عن هذا الإجراء.',
                  style: TextStyle(color: deleteRed),
                ),
              ],
            ),
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
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
            fontSize: 20,
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
              fontSize: 16),
          unselectedLabelStyle: const TextStyle(
              fontFamily: 'Tajawal',
              fontWeight: FontWeight.normal,
              fontSize: 16),
          tabs: const [
            Tab(text: 'المعلمين'),
            Tab(text: 'الطلاب'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UserManagementList<TeacherModel>(
            users: _teachers,
            itemBuilder: (context, teacher) => _UserListItem(
              name: teacher.fullName,
              detail: teacher.email,
              imageUrl: teacher.imageUrl,
              onEdit: () => _editTeacher(teacher),
              onDelete: () => _deleteTeacher(teacher),
            ),
            onAdd: _addTeacher,
            addLabel: 'إضافة معلم جديد',
          ),
          _UserManagementList<StudentModel>(
            users: _students,
            itemBuilder: (context, student) => _UserListItem(
              name: student.fullName,
              detail: student.fullClassDescription,
              imageUrl: student.imageUrl,
              onEdit: () => _editStudent(student),
              onDelete: () => _deleteStudent(student),
            ),
            onAdd: _addStudent,
            addLabel: 'إضافة طالب جديد',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAdmin,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.admin_panel_settings_outlined),
        label: const Text('إضافة مسؤول',
            style: TextStyle(fontFamily: 'Tajawal')),
      ),
    );
  }
}

// --- Generic List Widget ---
class _UserManagementList<T> extends StatelessWidget {
  final List<T> users;
  final Widget Function(BuildContext, T) itemBuilder;
  final VoidCallback onAdd;
  final String addLabel;

  const _UserManagementList({
    super.key,
    required this.users,
    required this.itemBuilder,
    required this.onAdd,
    required this.addLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: Text(addLabel,
                style:
                    const TextStyle(fontSize: 15, fontFamily: 'Tajawal')),
            style: ElevatedButton.styleFrom(
              backgroundColor: _AdminSettingsScreenState.primaryGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 1,
            ),
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? Center(
                  child: Text(
                    'لا يوجد ${addLabel.split(' ').last} حالياً',
                    style: const TextStyle(
                        color: _AdminSettingsScreenState.secondaryText),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) =>
                      itemBuilder(context, users[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                ),
        ),
      ],
    );
  }
}

// --- List Item Widget ---
class _UserListItem extends StatelessWidget {
  final String name;
  final String detail;
  final String imageUrl;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserListItem({
    required this.name,
    required this.detail,
    required this.imageUrl,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(imageUrl),
            backgroundColor: Colors.grey[200],
            onBackgroundImageError: (exception, stackTrace) {
              print('Error loading avatar: $exception');
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Tajawal',
                    color: _AdminSettingsScreenState.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Tajawal',
                    color: _AdminSettingsScreenState.secondaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined,
                color: _AdminSettingsScreenState.editBlue, size: 22),
            onPressed: onEdit,
            tooltip: 'تعديل',
            splashRadius: 20,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: _AdminSettingsScreenState.deleteRed, size: 22),
            onPressed: onDelete,
            tooltip: 'حذف',
            splashRadius: 20,
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}