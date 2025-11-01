import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/lesson_model.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/screens/timetable/data/admin/admin_time_table_cubit.dart';

class AdminTimetablePage extends StatelessWidget {
  const AdminTimetablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminTimetableCubit(),
      child: const _AdminTimetableView(),
    );
  }
}

class _AdminTimetableView extends StatefulWidget {
  const _AdminTimetableView();

  @override
  State<_AdminTimetableView> createState() => _AdminTimetableViewState();
}

class _AdminTimetableViewState extends State<_AdminTimetableView> {
  List<TeacherModel> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    final cubit = context.read<AdminTimetableCubit>();
    final teachers = await cubit.fetchAllTeachers();
    setState(() => _teachers = teachers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الجداول اليومية')),
      body: _teachers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text(
                'يمكنك إضافة أو تعديل الجداول اليومية لكل صف',
                style: TextStyle(fontSize: 16),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('إضافة جدول جديد'),
        onPressed: () => _openAddDaySheet(context),
      ),
    );
  }

  void _openAddDaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddDaySheet(teachers: _teachers),
    );
  }
}

class _AddDaySheet extends StatefulWidget {
  final List<TeacherModel> teachers;
  const _AddDaySheet({required this.teachers});

  @override
  State<_AddDaySheet> createState() => _AddDaySheetState();
}

class _AddDaySheetState extends State<_AddDaySheet> {
  final _formKey = GlobalKey<FormState>();
  final _lessons = <LessonModel>[];
  Grade? _grade;
  int? _classNumber;
  final DateTime _date = DateTime.now();
  final List<SchoolSubject> _subjects = SchoolSubject.values;

  void _addLesson({bool isBreak = false}) {
    DateTime start;
    if (_lessons.isEmpty) {
      start = DateTime(_date.year, _date.month, _date.day, 7, 45);
    } else {
      final last = _lessons.last;
      // Always add 5 min gap after a break
      if (last.isBreak) {
        start = last.endTime.toDate().add(const Duration(minutes: 5));
      } else {
        start = last.endTime.toDate();
      }
    }

    final durationMinutes = isBreak ? 15 : 45;
    final end = start.add(Duration(minutes: durationMinutes));

    final lesson = LessonModel(
      id: UniqueKey().toString(),
      startTime: Timestamp.fromDate(start),
      endTime: Timestamp.fromDate(end),
      duration: durationMinutes,
      isBreak: isBreak,
      breakTitle: isBreak ? 'استراحة' : '',
      subject: isBreak ? null : _subjects.first,
      teacher: isBreak ? null : null,
    );

    setState(() => _lessons.add(lesson));
  }

  Future<void> _saveDay() async {
    if (_grade == null || _classNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار الصف ورقم الفصل')),
      );
      return;
    }

    final timetableId =
        '${_date.year}_${_grade!.label}_${_classNumber}_${DateFormat("yyyyMMdd").format(_date)}';

    final existing = await FirebaseFirestore.instance
        .collection('timetables')
        .doc(timetableId)
        .get();

    if (existing.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يوجد جدول لهذا الصف في هذا اليوم بالفعل'),
        ),
      );
      return;
    }

    final timetable = TimetableModel(
      id: timetableId,
      grade: _grade!,
      classNumber: _classNumber!,
      date: _date,
      lessons: _lessons,
    );

    context.read<AdminTimetableCubit>().addOrUpdateTimetable(timetable);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lessonsCount = _lessons.where((l) => !l.isBreak).length;
    final breaksCount = _lessons.where((l) => l.isBreak).length;

    final isTimetableComplete = lessonsCount == 7 && breaksCount == 2;

    // Conditions
    final canAddLesson = lessonsCount < 7;
    bool canAddBreak = false;

    // break logic:
    if (breaksCount == 0 && lessonsCount >= 2 && lessonsCount <= 4) {
      canAddBreak = true;
    } else if (breaksCount == 1 && lessonsCount >= 5 && lessonsCount < 6) {
      canAddBreak = true;
    }

    // Prevent adding two breaks in a row
    if (_lessons.isNotEmpty && _lessons.last.isBreak) {
      canAddBreak = false;
    }

    final showAddButtons =
        (canAddLesson || canAddBreak) && _grade != null && _classNumber != null;

    return BlocConsumer<AdminTimetableCubit, AdminTimetableState>(
      listener: (context, state) {
        if (state is AdminTimetableSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is AdminTimetableError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text(
                  'إضافة جدول يومي',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Grade>(
                  decoration: const InputDecoration(labelText: 'الصف'),
                  items: Grade.values
                      .map(
                        (g) => DropdownMenuItem(value: g, child: Text(g.label)),
                      )
                      .toList(),
                  onChanged: (g) => setState(() => _grade = g),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'رقم الفصل'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      setState(() => _classNumber = int.tryParse(v.trim())),
                ),
                const SizedBox(height: 16),

                if (_grade != null && _classNumber != null) ...[
                  ..._lessons.map(
                    (lesson) => _LessonCard(
                      lesson: lesson,
                      subjects: _subjects,
                      allTeachers: widget.teachers,
                      selectedGrade: _grade,
                      onUpdate: (updatedLesson) {
                        final index = _lessons.indexOf(lesson);
                        if (index != -1) {
                          setState(() => _lessons[index] = updatedLesson);
                        }
                      },
                      onRemove: () {
                        setState(() => _lessons.remove(lesson));
                      },
                    ),
                  ),

                  const SizedBox(height: 8),
                  if (showAddButtons)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (canAddLesson)
                          ElevatedButton.icon(
                            onPressed: _addLesson,
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة حصة'),
                          ),
                        if (canAddBreak)
                          ElevatedButton.icon(
                            onPressed: () => _addLesson(isBreak: true),
                            icon: const Icon(Icons.free_breakfast),
                            label: const Text('إضافة استراحة'),
                          ),
                      ],
                    ),

                  if (isTimetableComplete) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ الجدول'),
                      onPressed: _saveDay,
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LessonCard extends StatefulWidget {
  final LessonModel lesson;
  final List<SchoolSubject> subjects;
  final List<TeacherModel> allTeachers;
  final Grade? selectedGrade;
  final ValueChanged<LessonModel> onUpdate;
  final VoidCallback onRemove;

  const _LessonCard({
    required this.lesson,
    required this.subjects,
    required this.allTeachers,
    required this.onUpdate,
    required this.onRemove,
    required this.selectedGrade,
  });

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  late SchoolSubject _subject;
  TeacherModel? _teacher;
  List<TeacherModel> _filteredTeachers = [];

  @override
  void initState() {
    super.initState();
    _subject = widget.lesson.subject ?? widget.subjects.first;
    _filterTeachers();
    _teacher =
        widget.lesson.teacher ??
        (_filteredTeachers.isNotEmpty ? _filteredTeachers.first : null);
  }

  void _filterTeachers() {
    _filteredTeachers = widget.allTeachers.where((t) {
      final subjectMatch = t.subjects.contains(_subject);
      final gradeMatch = widget.selectedGrade == null
          ? true
          : t.grades.contains(widget.selectedGrade!.index + 6);
      return subjectMatch && gradeMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final start = DateFormat.Hm().format(widget.lesson.startTime.toDate());
    final end = DateFormat.Hm().format(widget.lesson.endTime.toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: widget.lesson.isBreak
            ? Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.lesson.breakTitle!.isNotEmpty
                              ? widget.lesson.breakTitle!
                              : 'استراحة',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        Text('من $start إلى $end'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<SchoolSubject>(
                          value: _subject,
                          decoration: const InputDecoration(
                            labelText: 'المادة',
                          ),
                          items: widget.subjects
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.name),
                                ),
                              )
                              .toList(),
                          onChanged: (s) {
                            if (s != null) {
                              setState(() {
                                _subject = s;
                                _filterTeachers();
                                _teacher = _filteredTeachers.isNotEmpty
                                    ? _filteredTeachers.first
                                    : null;
                              });
                              widget.onUpdate(
                                widget.lesson.copyWith(
                                  subject: s,
                                  teacher: _teacher,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<TeacherModel>(
                          value: _teacher,
                          decoration: const InputDecoration(
                            labelText: 'المعلم',
                          ),
                          items: _filteredTeachers
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(t.fullName),
                                ),
                              )
                              .toList(),
                          onChanged: (t) {
                            if (t != null) {
                              setState(() => _teacher = t);
                              widget.onUpdate(
                                widget.lesson.copyWith(teacher: t),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('من $start إلى $end'),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: widget.onRemove,
                  ),
                ],
              ),
      ),
    );
  }
}
