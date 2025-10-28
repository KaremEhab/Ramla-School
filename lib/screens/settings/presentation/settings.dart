import 'package:flutter/material.dart';
// Import your user models and constants (adjust paths as needed)
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/models/lesson_model.dart'; // Needed for TeacherModel mock
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Timestamp in mock

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
  static const Color screenBg = Color(0xFFF8F8F8); // Light grey background


  // --- Mock Data ---
  // Replace with actual data fetched from your backend/state management
  // Using late initialization and populating in initState to avoid static issues if models become complex
  late List<TeacherModel> _teachers;
  late List<StudentModel> _students;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateMockData(); // Populate mock data here
  }

  void _generateMockData() {
     _teachers = List.generate(
      5,
      (index) => TeacherModel(
        id: 't${index + 1}',
        firstName: 'معلمة',
        lastName: '${index + 1}',
        email: 'teacher${index + 1}@example.com',
        imageUrl: 'https://placehold.co/80x80/A0D9A4/333333?text=T${index + 1}', // Greenish placeholder
        status: UserStatus.offline,
        gender: Gender.female,
        createdAt: DateTime.now().subtract(Duration(days: index * 10)),
        subjects: [LessonModel( // Ensure LessonModel constructor matches
            id: 'sub$index',
            subject: SchoolSubject.values[index % SchoolSubject.values.length],
            isBreak: false,
            breakTitle: '',
            duration: 45,
            startTime: Timestamp.now(),
            endTime: Timestamp.now()
        )],
      ),
    );

     _students = List.generate(
      8,
      (index) => StudentModel(
        id: 's${index + 1}',
        firstName: 'طالبة',
        lastName: '${index + 1}',
        email: 'student${index + 1}@example.com',
        imageUrl: 'https://placehold.co/80x80/FFDDC1/333333?text=S${index + 1}', // Orangish placeholder
        status: UserStatus.offline,
        gender: Gender.female,
        createdAt: DateTime.now().subtract(Duration(days: index * 5)),
        grade: 6 + (index % 4), // Example grades 6-9
        classNumber: (index % 3) + 1, // Example classes 1-3
      ),
    );
  }


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- Action Handlers (Placeholders) ---
   void _addTeacher() {
      // TODO: Navigate to Add Teacher Form/Screen
      print('Add New Teacher Action');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigate to Add Teacher Form')));
   }
   void _editTeacher(TeacherModel teacher) {
       // TODO: Navigate to Edit Teacher Form/Screen, passing teacher data
       print('Edit ${teacher.fullName}');
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigate to Edit Teacher: ${teacher.fullName}')));
   }
    void _deleteTeacher(TeacherModel teacher) {
       // TODO: Show confirmation dialog, then call delete logic
       print('Delete ${teacher.fullName}');
        _showDeleteConfirmation(context, teacher.fullName, () {
          // Actual delete logic here
           print('Confirmed Deletion of ${teacher.fullName}');
           setState(() {
             _teachers.removeWhere((t) => t.id == teacher.id); // Remove from mock list
           });
        });
   }

   void _addStudent() {
      // TODO: Navigate to Add Student Form/Screen
       print('Add New Student Action');
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigate to Add Student Form')));
   }
   void _editStudent(StudentModel student) {
      // TODO: Navigate to Edit Student Form/Screen, passing student data
       print('Edit ${student.fullName}');
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Navigate to Edit Student: ${student.fullName}')));
   }
    void _deleteStudent(StudentModel student) {
       // TODO: Show confirmation dialog, then call delete logic
       print('Delete ${student.fullName}');
        _showDeleteConfirmation(context, student.fullName, () {
          // Actual delete logic here
           print('Confirmed Deletion of ${student.fullName}');
           setState(() {
              _students.removeWhere((s) => s.id == student.id); // Remove from mock list
           });
        });
   }

   void _addAdmin() {
       // TODO: Navigate to Add Admin Form/Screen or show Dialog
       print('Add New Admin Action');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Navigate to Add Admin Form')));
   }

  // --- Delete Confirmation Dialog ---
   Future<void> _showDeleteConfirmation(BuildContext context, String userName, VoidCallback onConfirm) async {
     return showDialog<void>(
       context: context,
       barrierDismissible: false, // User must tap button
       builder: (BuildContext dialogContext) {
         return AlertDialog(
           title: const Text('تأكيد الحذف'),
           content: SingleChildScrollView(
             child: ListBody(
               children: <Widget>[
                 Text('هل أنت متأكد من رغبتك في حذف المستخدم "$userName"؟'),
                 const Text('لا يمكن التراجع عن هذا الإجراء.', style: TextStyle(color: deleteRed)),
               ],
             ),
           ),
           actions: <Widget>[
             TextButton(
               child: const Text('إلغاء'),
               onPressed: () {
                 Navigator.of(dialogContext).pop(); // Close the dialog
               },
             ),
             TextButton(
                style: TextButton.styleFrom(foregroundColor: deleteRed),
               child: const Text('حذف'),
               onPressed: () {
                 Navigator.of(dialogContext).pop(); // Close the dialog
                 onConfirm(); // Execute the delete action
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
        // --- Shadowless AppBar ---
        backgroundColor: Colors.white, // White AppBar background
        elevation: 0,
        scrolledUnderElevation: 0,
        // forceMaterialTransparency: true, // Use shape border instead for subtle line
         shape: const Border(bottom: BorderSide(color: dividerColor, width: 0.5)), // Subtle bottom border
        // --- End Shadowless AppBar ---
        centerTitle: true,
        automaticallyImplyLeading: false, // No back button
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
            fontFamily: 'Tajawal', fontWeight: FontWeight.bold, fontSize: 16),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal', fontWeight: FontWeight.normal, fontSize: 16),
          tabs: const [
            Tab(text: 'المعلمين'),
            Tab(text: 'الطلاب'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Teachers Tab ---
          _UserManagementList<TeacherModel>(
            users: _teachers,
            itemBuilder: (context, teacher) => _UserListItem(
              name: teacher.fullName,
              detail: teacher.email, // Or subjects display
              imageUrl: teacher.imageUrl,
              onEdit: () => _editTeacher(teacher),
              onDelete: () => _deleteTeacher(teacher),
            ),
            onAdd: _addTeacher,
            addLabel: 'إضافة معلم جديد',
          ),

          // --- Students Tab ---
           _UserManagementList<StudentModel>(
            users: _students,
            itemBuilder: (context, student) => _UserListItem(
              name: student.fullName,
              detail: student.fullClassDescription, // Show class info
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
        label: const Text('إضافة مسؤول', style: TextStyle(fontFamily: 'Tajawal')),
      ),
    );
  }
}

// --- Generic List Widget for Teachers/Students ---
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
             label: Text(addLabel, style: const TextStyle(fontSize: 15, fontFamily: 'Tajawal')),
             style: ElevatedButton.styleFrom(
               backgroundColor: _AdminSettingsScreenState.primaryGreen,
               foregroundColor: Colors.white,
               minimumSize: const Size(double.infinity, 45), // Full width
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 1, // Slight elevation
             ),
          ),
        ),
        Expanded(
          child: users.isEmpty
              ? Center(child: Text('لا يوجد ${addLabel.split(' ').last} حالياً', style: const TextStyle(color: _AdminSettingsScreenState.secondaryText))) // e.g., لا يوجد معلمين حالياً
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: users.length,
                  itemBuilder: (context, index) => itemBuilder(context, users[index]),
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
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
       padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
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
             onBackgroundImageError:(exception, stackTrace) {
                  print('Error loading list item avatar: $exception');
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
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    fontSize: 13,
                     fontFamily: 'Tajawal',
                    color: _AdminSettingsScreenState.secondaryText,
                  ),
                   maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Action Buttons
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: _AdminSettingsScreenState.editBlue, size: 22),
            onPressed: onEdit,
            tooltip: 'تعديل', // Tooltip for accessibility
            splashRadius: 20,
            constraints: const BoxConstraints(), // Reduce default padding
            padding: const EdgeInsets.symmetric(horizontal: 8),

          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: _AdminSettingsScreenState.deleteRed, size: 22),
            onPressed: onDelete,
             tooltip: 'حذف',
             splashRadius: 20,
             constraints: const BoxConstraints(), // Reduce default padding
             padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

// Ensure the necessary models (TeacherModel, StudentModel, LessonModel)
// and enums (UserStatus, Gender, SchoolSubject, Grade) are defined and imported correctly.
// Placeholder for DocumentModel if needed by LessonModel initialization
// class DocumentModel {
//   final String id; final String title; final String subject;
//   final DateTime createdAt; final String thumbnailUrl; final String documentUrl;
//   DocumentModel({ required this.id, required this.title, required this.subject, required this.createdAt, required this.thumbnailUrl, required this.documentUrl});
// }