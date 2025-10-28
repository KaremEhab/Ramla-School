import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/admin_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/models/users/user_model.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  List<UserModel> users = [];

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    users = [
      AdminModel(
        id: '1',
        firstName: 'Kareem',
        lastName: 'Ehab',
        email: 'kareem@example.com',
        imageUrl: '',
        status: UserStatus.online,
        gender: Gender.male,
        createdAt: DateTime.now(),
      ),
      TeacherModel(
        id: '2',
        firstName: 'Ali',
        lastName: 'Hassan',
        email: 'ali.hassan@example.com',
        imageUrl: '',
        status: UserStatus.offline,
        gender: Gender.male,
        createdAt: DateTime.now(),
        subjects: [
          SchoolSubject.math,
          SchoolSubject.arabic,
        ],
      ),
      StudentModel(
        id: '3',
        firstName: 'Mona',
        lastName: 'Ahmed',
        email: 'mona.ahmed@example.com',
        imageUrl: '',
        status: UserStatus.online,
        gender: Gender.female,
        createdAt: DateTime.now(),
        grade: 9,
        classNumber: 1,
      ),
    ];
  }

  void _openAddUserSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        UserRole? selectedRole;
        final firstNameController = TextEditingController();
        final lastNameController = TextEditingController();
        final emailController = TextEditingController();
        final gender = ValueNotifier<Gender>(Gender.male);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create New Account',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<UserRole>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'User Role',
                      border: OutlineInputBorder(),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setModalState(() => selectedRole = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: gender,
                    builder: (context, g, _) {
                      return DropdownButtonFormField<Gender>(
                        value: g,
                        decoration: const InputDecoration(
                          labelText: 'Gender',
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
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text(
                      'Create Account',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () {
                      if (selectedRole == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please select a role first.'),
                          ),
                        );
                        return;
                      }

                      final newUser = switch (selectedRole!) {
                        UserRole.admin => AdminModel(
                            id: Random().nextInt(1000).toString(),
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            imageUrl: '',
                            status: UserStatus.online,
                            gender: gender.value,
                            createdAt: DateTime.now(),
                          ),
                        UserRole.teacher => TeacherModel(
                            id: Random().nextInt(1000).toString(),
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            imageUrl: '',
                            status: UserStatus.online,
                            gender: gender.value,
                            createdAt: DateTime.now(),
                            subjects: [SchoolSubject.math],
                          ),
                        UserRole.student => StudentModel(
                            id: Random().nextInt(1000).toString(),
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            imageUrl: '',
                            status: UserStatus.online,
                            gender: gender.value,
                            createdAt: DateTime.now(),
                            grade: 10,
                            classNumber: 2,
                          ),
                      };

                      setState(() {
                        users.add(newUser);
                      });

                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy – hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddUserSheet,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.shade100,
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(user.fullName),
              subtitle: Text(
                '${user.role.name.toUpperCase()} • ${_formatDate(user.createdAt)}',
              ),
              trailing: Icon(
                user.status == UserStatus.online
                    ? Icons.circle
                    : Icons.circle_outlined,
                color: user.status == UserStatus.online
                    ? Colors.green
                    : Colors.grey,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}