import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/lesson_model.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/screens/timetable/data/admin/admin_time_table_cubit.dart';

class AdminTimetablePage extends StatefulWidget {
  const AdminTimetablePage({super.key});

  @override
  State<AdminTimetablePage> createState() => _AdminTimetablePageState();
}

class _AdminTimetablePageState extends State<AdminTimetablePage> {
  List<TeacherModel> _teachers = [];
  List<TimetableModel> _timetables = [];
  int? _selectedYear;
  int? _selectedMonth;
  // NEW: State for selected Grade
  Grade? _selectedGrade;

  @override
  void initState() {
    super.initState();
    // Use WidgetsBinding to ensure context is available for cubit read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeachers();
      _fetchAllTimetables();
    });
  }

  Future<void> _loadTeachers() async {
    // We assume the Cubit is provided higher up, or we use a Builder.
    // Given the structure, context.read is correct here.
    final cubit = context.read<AdminTimetableCubit>();
    final teachers = await cubit.fetchAllTeachers();
    setState(() => _teachers = teachers);
  }

  Future<void> _fetchAllTimetables() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .get();

    final timetables = snapshot.docs.map((doc) {
      // Use the safe spread operator for mapping
      return TimetableModel.fromMap({...doc.data(), 'id': doc.id});
    }).toList();

    setState(() => _timetables = timetables);
  }

  List<int> get _availableYears {
    final years = _timetables.map((t) => t.date.year).toSet().toList();
    years.sort();
    return years;
  }

  List<int> get _availableMonths {
    if (_selectedYear == null) return [];
    final months = _timetables
        .where((t) => t.date.year == _selectedYear)
        .map((t) => t.date.month)
        .toSet()
        .toList();
    months.sort();
    return months;
  }

  // NEW: Getter for available Grades
  List<Grade> get _availableGrades {
    final grades = _timetables.map((t) => t.grade).toSet().toList();
    // Assuming Grade enum has a natural order (e.g., Grade6, Grade7, ...)
    // grades.sort((a, b) => a.index.compareTo(b.index));
    return grades;
  }

  // UPDATED: Filtering now includes the selected Grade
  List<TimetableModel> _filteredTimetables() {
    return _timetables.where((t) {
      final yearOk = _selectedYear == null || t.date.year == _selectedYear;
      final monthOk = _selectedMonth == null || t.date.month == _selectedMonth;
      // NEW FILTER: Check if the timetable's grade matches the selected grade
      final gradeOk = _selectedGrade == null || t.grade == _selectedGrade;
      return yearOk && monthOk && gradeOk;
    }).toList();
  }

  void _openClassTimetables(BuildContext context, int grade, int classNumber) {
    final filtered =
        _filteredTimetables()
            .where(
              (t) => t.grade.index + 6 == grade && t.classNumber == classNumber,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    showModalBottomSheet(
      context: context,
      backgroundColor: screenBg,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: _ClassTimetableList(
          grade: grade,
          classNumber: classNumber,
          timetables: filtered,
          teachers: _teachers,
          onUpdated: _fetchAllTimetables,
        ),
      ),
    );
  }

  void _openAddDaySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: screenBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: _AddDaySheet(teachers: _teachers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTimetables();

    // Collect unique grade/class combinations
    final classGroups = <String, Map<String, dynamic>>{};
    for (final t in filtered) {
      final key = '${t.grade.label}-${t.classNumber}';
      classGroups[key] = {'grade': t.grade, 'classNumber': t.classNumber};
    }

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: screenBg, // Match screen background
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false, // No back button
        // --- End Shadowless AppBar ---
        centerTitle: true, // Center the title
        title: Text(
          'إدارة الجداول الأسبوعية',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70), // height of the filter row
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Year Filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: screenBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dividerColor),
                    ),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('السنة'),
                      value: _selectedYear,
                      underline: const SizedBox(),
                      items: _availableYears
                          .map(
                            (y) =>
                                DropdownMenuItem(value: y, child: Text('$y')),
                          )
                          .toList(),
                      onChanged: (y) => setState(() {
                        _selectedYear = y;
                        _selectedMonth = null;
                      }),
                    ),
                  ),
                ),

                const SizedBox(width: 8), // Reduced spacing
                // Month Filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: screenBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dividerColor),
                    ),
                    child: DropdownButton<int>(
                      isExpanded: true,
                      hint: const Text('الشهر'),
                      value: _selectedMonth,
                      underline: const SizedBox(),
                      items: _availableMonths
                          .map(
                            (m) =>
                                DropdownMenuItem(value: m, child: Text('$m')),
                          )
                          .toList(),
                      onChanged: (m) => setState(() => _selectedMonth = m),
                    ),
                  ),
                ),

                const SizedBox(width: 8), // Reduced spacing
                // NEW: Grade Filter
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: screenBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: dividerColor),
                    ),
                    child: DropdownButton<Grade>(
                      isExpanded: true,
                      hint: const Text('الصف'),
                      value: _selectedGrade,
                      underline: const SizedBox(),
                      items: _availableGrades
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(g.label),
                            ),
                          )
                          .toList(),
                      onChanged: (g) => setState(() => _selectedGrade = g),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _teachers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : classGroups.isEmpty
          ? const Center(
              child: Text(
                'لا توجد جداول متاحة للشهور المختارة',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: classGroups.entries.map((entry) {
                final grade = entry.value['grade'] as Grade;
                final classNum = entry.value['classNumber'] as int;
                return GestureDetector(
                  onTap: () =>
                      _openClassTimetables(context, grade.index + 6, classNum),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryGreen.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryGreen, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الصف ${grade.label} / فصل $classNum',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        foregroundColor: screenBg,
        icon: const Icon(Icons.add),
        label: const Text('إضافة جدول جديد'),
        onPressed: () => _openAddDaySheet(context),
      ),
    );
  }
}

// ================= CLASS TIMETABLES LIST ===================
class _ClassTimetableList extends StatefulWidget {
  final int grade;
  final int classNumber;
  final List<TimetableModel> timetables;
  final List<TeacherModel> teachers;
  final VoidCallback onUpdated;

  const _ClassTimetableList({
    required this.grade,
    required this.classNumber,
    required this.timetables,
    required this.teachers,
    required this.onUpdated,
  });

  @override
  State<_ClassTimetableList> createState() => _ClassTimetableListState();
}

class _ClassTimetableListState extends State<_ClassTimetableList> {
  int? _selectedYear;
  int? _selectedMonth;
  int? _selectedDay;

  List<int> get _availableYears {
    final years = widget.timetables.map((t) => t.date.year).toSet().toList();
    years.sort();
    return years;
  }

  List<int> get _availableMonths {
    if (_selectedYear == null) return [];
    final months = widget.timetables
        .where((t) => t.date.year == _selectedYear)
        .map((t) => t.date.month)
        .toSet()
        .toList();
    months.sort();
    return months;
  }

  List<int> get _availableDays {
    if (_selectedYear == null || _selectedMonth == null) return [];
    final days = widget.timetables
        .where(
          (t) => t.date.year == _selectedYear && t.date.month == _selectedMonth,
        )
        .map((t) => t.date.day)
        .toSet()
        .toList();
    days.sort();
    return days;
  }

  List<TimetableModel> get _filteredTimetables {
    return widget.timetables.where((t) {
      final yearOk = _selectedYear == null || t.date.year == _selectedYear;
      final monthOk = _selectedMonth == null || t.date.month == _selectedMonth;
      final dayOk = _selectedDay == null || t.date.day == _selectedDay;
      return yearOk && monthOk && dayOk;
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  void _openEditSheet(TimetableModel timetable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: screenBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: _EditTimetableSheet(
          timetable: timetable,
          teachers: widget.teachers,
          onUpdated: widget.onUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTimetables;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "جداول الصف ${widget.grade} / الفصل ${widget.classNumber}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Year Field
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: textFieldFill,
                    labelText: 'السنة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _selectedYear,
                  items: _availableYears
                      .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                      .toList(),
                  onChanged: (y) => setState(() {
                    _selectedYear = y;
                    _selectedMonth = null;
                    _selectedDay = null;
                  }),
                ),
              ),
              const SizedBox(width: 12),

              // Month Field
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: textFieldFill,
                    labelText: 'الشهر',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _selectedMonth,
                  items: _availableMonths
                      .map((m) => DropdownMenuItem(value: m, child: Text('$m')))
                      .toList(),
                  onChanged: (m) => setState(() {
                    _selectedMonth = m;
                    _selectedDay = null;
                  }),
                ),
              ),
              const SizedBox(width: 12),

              // Day Field
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: textFieldFill,
                    labelText: 'اليوم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _selectedDay,
                  items: _availableDays
                      .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                      .toList(),
                  onChanged: (d) => setState(() => _selectedDay = d),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد جداول محفوظة لهذا الصف في التاريخ المحدد.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final t = filtered[index];
                    final date = t.date;
                    final formattedDate = DateFormat('yyyy/MM/dd').format(date);

                    // Convert weekday number to Arabic day
                    final arabicDays = {
                      1: 'الإثنين',
                      2: 'الثلاثاء',
                      3: 'الأربعاء',
                      4: 'الخميس',
                      5: 'الجمعة',
                      6: 'السبت',
                      7: 'الأحد',
                    };
                    // Note: date.weekday is 1 (Mon) - 7 (Sun). We map to the desired Arabic day.
                    final dayLabel = "جدول يوم ${arabicDays[date.weekday]}";

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.only(right: 14),
                        title: Text(
                          dayLabel,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(formattedDate),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                IconlyBold.edit,
                                color: primaryGreen,
                              ),
                              onPressed: () => _openEditSheet(t),
                            ),
                            IconButton(
                              icon: const Icon(
                                IconlyBold.delete,
                                color: offlineIndicator,
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('تأكيد الحذف'),
                                    content: const Text(
                                      'هل أنت متأكد من حذف هذا الجدول؟',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('إلغاء'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Delete from your cubit
                                          await context
                                              .read<AdminTimetableCubit>()
                                              .deleteTimetable(
                                                widget.timetables[index].id,
                                              );

                                          // Optionally delete from Firestore directly if needed
                                          await FirebaseFirestore.instance
                                              .collection('timetables')
                                              .doc(widget.timetables[index].id)
                                              .delete();

                                          if (!context.mounted) return;
                                          Navigator.pop(
                                            context,
                                            true,
                                          ); // Return true to the dialog
                                        },
                                        child: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  // Call your update callback
                                  widget.onUpdated();

                                  // Navigate back
                                  if (!context.mounted) return;
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ================ EDIT TIMETABLE SHEET ====================

class _EditTimetableSheet extends StatefulWidget {
  final TimetableModel timetable;
  final List<TeacherModel> teachers;
  final VoidCallback onUpdated;

  const _EditTimetableSheet({
    required this.timetable,
    required this.teachers,
    required this.onUpdated,
  });

  @override
  State<_EditTimetableSheet> createState() => _EditTimetableSheetState();
}

class _EditTimetableSheetState extends State<_EditTimetableSheet> {
  // We only need to store the mutable list of lessons
  late List<LessonModel> _lessons;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the list
    _lessons = List.from(widget.timetable.lessons);
  }

  /// Updates a lesson in the local _lessons list
  void _updateLesson(LessonModel updatedLesson) {
    final index = _lessons.indexWhere((l) => l.id == updatedLesson.id);
    if (index != -1) {
      setState(() {
        _lessons[index] = updatedLesson;
      });
    }
  }

  /// Removes a lesson from the local _lessons list
  void _removeLesson(String lessonId) {
    setState(() {
      _lessons.removeWhere((l) => l.id == lessonId);
    });
  }

  Future<void> _saveChanges() async {
    // Use the locally modified _lessons list
    final updated = widget.timetable.copyWith(lessons: _lessons);

    try {
      await FirebaseFirestore.instance
          .collection('timetables')
          .doc(widget.timetable.id)
          .update(updated.toMap());

      widget.onUpdated();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      // Handle save error (e.g., show a snackbar)
      log('Error saving timetable: $e');
    }
  }

  // Helper to extract the integer grade from the TimetableModel for teacher filtering
  Grade get _timetableGrade {
    // Assuming Grade is an enum where index 0 maps to grade 6, index 1 to grade 7, etc.
    return widget.timetable.grade;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تعديل الجدول',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Iterate over the mutable lessons list and use the new card widget
            ..._lessons.map(
              (lesson) => LessonEditCard(
                key: ValueKey(
                  lesson.id,
                ), // Key is essential for list performance and widget identity
                lesson: lesson,
                allSubjects: SchoolSubject.values,
                allTeachers: widget.teachers,
                selectedGrade: _timetableGrade,
                onUpdate: _updateLesson,
                onRemove: () => _removeLesson(lesson.id),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: screenBg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: const Text(
                  'حفظ التعديلات',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
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
  // We make lessons non-late so we can modify them during save.
  final _lessons = <LessonModel>[];
  Grade? _grade;
  int? _classNumber;
  final List<SchoolSubject> _subjects = SchoolSubject.values;

  // Already used dates for selected grade/class
  Set<String> _usedDates = {};

  // Map للأيام بالإنجليزي مع حالة الاختيار
  final Map<String, bool> _selectedDays = {
    'Sun': false,
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
    'Sat': false,
  };

  final Map<String, String> _arabicDays = {
    'Sun': 'الأحد',
    'Mon': 'الإثنين',
    'Tue': 'الثلاثاء',
    'Wed': 'الأربعاء',
    'Thu': 'الخميس',
    'Fri': 'الجمعة',
    'Sat': 'السبت',
  };

  void _addLesson({bool isBreak = false}) {
    DateTime start;
    // NOTE: Lessons are created with today's date, but the correct date is applied in _saveDay.
    final today = DateTime.now();

    if (_lessons.isEmpty) {
      start = DateTime(
        today.year,
        today.month,
        today.day,
        7,
        45, // 7:45 AM
      );
    } else {
      final last = _lessons.last;
      // Get hour/minute from last lesson's end time, but set to today's date
      final lastEndTime = last.endTime.toDate();
      start = DateTime(
        today.year,
        today.month,
        today.day,
        lastEndTime.hour,
        lastEndTime.minute,
      ).add(Duration(minutes: last.isBreak ? 5 : 0));
    }

    final durationMinutes = isBreak ? 15 : 45;
    final end = start.add(Duration(minutes: durationMinutes));

    final lesson = LessonModel(
      id: UniqueKey().toString(),
      // startTime and endTime now hold the correct time, but today's date.
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

  Future<void> _fetchUsedDates() async {
    if (_grade == null || _classNumber == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('timetables')
        .where('grade', isEqualTo: _grade!.label)
        .where('classNumber', isEqualTo: _classNumber)
        .get();

    setState(() {
      _usedDates = snapshot.docs
          .map(
            (doc) => DateFormat(
              'yyyyMMdd',
            ).format((doc.data()['date'] as Timestamp).toDate()),
          )
          .toSet();
    });
  }

  Future<void> _saveDay() async {
    if (_grade == null || _classNumber == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار الصف ورقم الفصل')),
      );
      return;
    }

    final selectedDays = _selectedDays.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يجب اختيار يوم واحد على الأقل')),
      );
      return;
    }

    final today = DateTime.now();
    final todayWeekday = today.weekday; // 1=Mon .. 7=Sun
    List<DateTime> datesToSave = [];

    for (var day in selectedDays) {
      int offset = _dayOffsetFromToday(day, todayWeekday);
      final newDate = today.add(Duration(days: offset));
      final dateKey = DateFormat('yyyyMMdd').format(newDate);

      if (_usedDates.contains(dateKey)) continue; // skip already used date
      datesToSave.add(newDate);
    }

    if (datesToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('جميع الأيام المختارة موجودة بالفعل')),
      );
      return;
    }

    // --- FIX APPLIED HERE ---
    for (var targetDate in datesToSave) {
      // 1. Map existing lessons to new lessons with the correct date
      final lessonsForDay = _lessons.map((lesson) {
        final start = lesson.startTime.toDate();
        final end = lesson.endTime.toDate();

        // Use the hour/minute from the original time, but apply the targetDate's year/month/day
        final newStartTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          start.hour,
          start.minute,
        );
        final newEndTime = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
          end.hour,
          end.minute,
        );

        return lesson.copyWith(
          // Preserve the original unique ID from creation
          startTime: Timestamp.fromDate(newStartTime),
          endTime: Timestamp.fromDate(newEndTime),
        );
      }).toList();

      final timetableId =
          '${targetDate.year}_${_grade!.index + 6}_${_classNumber}_${DateFormat("yyyyMMdd").format(targetDate)}';

      final timetable = TimetableModel(
        id: timetableId,
        grade: _grade!,
        classNumber: _classNumber!,
        date: targetDate, // The timetable date is correct
        lessons: lessonsForDay, // Use the date-corrected lessons
      );

      await context.read<AdminTimetableCubit>().addOrUpdateTimetable(timetable);
    }
    // --- END FIX ---

    if (!mounted) return;
    Navigator.pop(context);
  }

  int _dayOffsetFromToday(String day, int todayWeekday) {
    final dayMap = {
      'Mon': 1,
      'Tue': 2,
      'Wed': 3,
      'Thu': 4,
      'Fri': 5,
      'Sat': 6,
      'Sun': 7,
    };
    int dayNum = dayMap[day]!;
    int offset = dayNum - todayWeekday;
    if (offset < 0) offset += 7;
    return offset;
  }

  @override
  Widget build(BuildContext context) {
    final lessonsCount = _lessons.where((l) => !l.isBreak).length;
    final breaksCount = _lessons.where((l) => l.isBreak).length;
    final isTimetableComplete = lessonsCount == 7 && breaksCount == 2;

    final canAddLesson = lessonsCount < 7;
    bool canAddBreak = false;

    if (breaksCount == 0 && lessonsCount >= 2 && lessonsCount <= 4) {
      canAddBreak = true;
    } else if (breaksCount == 1 && lessonsCount >= 5 && lessonsCount < 6) {
      canAddBreak = true;
    }
    if (_lessons.isNotEmpty && _lessons.last.isBreak) canAddBreak = false;

    final showAddButtons =
        (canAddLesson || canAddBreak) && _grade != null && _classNumber != null;

    final weekOrder = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'إضافة جدول يومي',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Grade>(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: textFieldFill,
                    labelText: 'الصف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _grade,
                  items: Grade.values
                      .map(
                        (g) => DropdownMenuItem(value: g, child: Text(g.label)),
                      )
                      .toList(),
                  onChanged: (g) {
                    setState(() => _grade = g);
                    _fetchUsedDates(); // fetch already used dates when grade changes
                  },
                ),
                const SizedBox(height: 25),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: textFieldFill,
                    labelText: 'رقم الفصل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    setState(() => _classNumber = int.tryParse(v));
                    _fetchUsedDates(); // fetch already used dates when class changes
                  },
                ),
                const SizedBox(height: 16),
                if (_grade != null && _classNumber != null)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: weekOrder.map((day) {
                      final today = DateTime.now();
                      final offset = _dayOffsetFromToday(day, today.weekday);
                      final date = today.add(Duration(days: offset));
                      final dateKey = DateFormat('yyyyMMdd').format(date);
                      final disabled = _usedDates.contains(dateKey);

                      return FilterChip(
                        label: Text(
                          _arabicDays[day]! + (disabled ? ' (محجوز)' : ''),
                        ),
                        selected: _selectedDays[day]!,
                        onSelected: disabled
                            ? null
                            : (val) => setState(() => _selectedDays[day] = val),
                        selectedColor: primaryGreen.withAlpha(
                          (0.2 * 255).round(),
                        ),
                        checkmarkColor: primaryGreen,
                        backgroundColor: disabled ? iconGrey : dividerColor,
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 12),
                ..._lessons.map(
                  (lesson) => Center(
                    child: _LessonCard(
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
                      onRemove: () => setState(() => _lessons.remove(lesson)),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                if (showAddButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (canAddLesson)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('إضافة حصة'),
                            onPressed: _addLesson,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: primaryGreen,
                              foregroundColor: screenBg,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      if (canAddBreak) const SizedBox(width: 12),
                      if (canAddBreak)
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.free_breakfast),
                            label: const Text('إضافة استراحة'),
                            onPressed: () => _addLesson(isBreak: true),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: yellowColor,
                              foregroundColor: primaryText,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                if (isTimetableComplete)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.save),
                          onPressed: _saveDay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            foregroundColor: screenBg,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          label: const Text(
                            'حفظ الجدول',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
}

// NOTE: This widget remains unchanged from your previous state,
// but it is not used in the _AddDaySheet now that LessonEditCard exists.
// I will keep it for completeness but recommend replacing all _LessonCard usages with LessonEditCard.
class _LessonCard extends StatefulWidget {
  final LessonModel lesson;
  final List<SchoolSubject> subjects;
  final List<TeacherModel> allTeachers;
  final Grade? selectedGrade;
  final void Function(LessonModel) onUpdate;
  final VoidCallback onRemove;

  const _LessonCard({
    required this.lesson,
    required this.subjects,
    required this.allTeachers,
    this.selectedGrade,
    required this.onUpdate,
    required this.onRemove,
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: widget.lesson.isBreak
          ? yellowColor.withAlpha((0.3 * 255).round())
          : primaryGreen.withAlpha((0.3 * 255).round()),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.lesson.isBreak
                      ? 'استراحة'
                      : widget.lesson.subject?.name ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: offlineIndicator),
                  onPressed: widget.onRemove,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Time info
            Text(
              'من ${DateFormat('HH:mm').format(widget.lesson.startTime.toDate())} إلى ${DateFormat('HH:mm').format(widget.lesson.endTime.toDate())}',
              style: TextStyle(color: secondaryText),
            ),

            const SizedBox(height: 8),

            // Optional: Teacher / Subject pickers
            if (!widget.lesson.isBreak)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<SchoolSubject>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldFill,
                        hint: const Text('المادة'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 8,
                        ),
                      ),
                      initialValue: widget.lesson.subject,
                      items: widget.subjects
                          .map(
                            (s) =>
                                DropdownMenuItem(value: s, child: Text(s.name)),
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
                  const SizedBox(width: 8), // small gap instead of Row.spacing
                  Expanded(
                    child: DropdownButtonFormField<TeacherModel>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: textFieldFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      initialValue: _teacher,
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
                          widget.onUpdate(widget.lesson.copyWith(teacher: t));
                        }
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ================= LESSON EDIT CARD (New Component) ===================

class LessonEditCard extends StatefulWidget {
  final LessonModel lesson;
  final List<SchoolSubject> allSubjects;
  final List<TeacherModel> allTeachers;
  final Grade selectedGrade; // Changed to required
  final void Function(LessonModel) onUpdate;
  final VoidCallback onRemove;

  const LessonEditCard({
    required this.lesson,
    required this.allSubjects,
    required this.allTeachers,
    required this.selectedGrade, // Ensure Grade is passed for filtering
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  State<LessonEditCard> createState() => _LessonEditCardState();
}

class _LessonEditCardState extends State<LessonEditCard> {
  late SchoolSubject? _subject;
  TeacherModel? _teacher;
  List<TeacherModel> _filteredTeachers = [];

  @override
  void initState() {
    super.initState();

    // 1. Initialize Subject (Crucial for Dropdown Display)
    // Find the correct instance from the full list for proper comparison.
    _subject =
        widget.allSubjects.firstWhereOrNull(
          (s) => s.name == widget.lesson.subject?.name,
        ) ??
        widget.allSubjects.firstOrNull;

    // 2. Initial filtering based on the provided lesson subject
    _filterTeachers(_subject);

    // 3. Initialize Teacher (Crucial for Dropdown Display)
    // Find the exact teacher from the filtered list using the ID of the fetched lesson's teacher.
    _teacher =
        _filteredTeachers.firstWhereOrNull(
          (t) => t.id == widget.lesson.teacher?.id,
        ) ??
        widget.lesson.teacher ??
        _filteredTeachers.firstOrNull;

    // FIX 1: Schedule the parent update AFTER the first frame is built, only if initial subject was null
    if (widget.lesson.subject == null && _subject != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyParentUpdate();
      });
    }
  }

  // Called when the parent widget rebuilds with a new lesson object (rare in this setup)
  @override
  void didUpdateWidget(covariant LessonEditCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lesson != oldWidget.lesson) {
      // Re-synchronize local state with widget property if the lesson object itself changed
      _subject =
          widget.allSubjects.firstWhereOrNull(
            (s) => s.name == widget.lesson.subject?.name,
          ) ??
          _subject;

      _teacher =
          widget.allTeachers.firstWhereOrNull(
            (t) => t.id == widget.lesson.teacher?.id,
          ) ??
          widget.lesson.teacher;

      _filterTeachers(_subject);
    }
  }

  void _filterTeachers(SchoolSubject? currentSubject) {
    if (currentSubject == null) {
      _filteredTeachers = [];
      return;
    }

    _filteredTeachers = widget.allTeachers.where((t) {
      // 1. Subject Match: Does the teacher teach the selected subject?
      // We compare by name for reliable string comparison
      final subjectMatch = t.subjects.any((s) => s.name == currentSubject.name);

      // 2. Grade Match: Does the teacher teach the currently selected grade?
      // Assuming 'grades' is a List<int> of grade numbers (e.g., [6, 7, 8])
      final gradeMatch = t.grades.contains(
        widget.selectedGrade.index + 6,
      ); // Adjust grade mapping as necessary

      return subjectMatch && gradeMatch;
    }).toList();

    // IMPORTANT FIX: If the previously selected teacher is no longer in the filtered list
    // (e.g., subject changed), update _teacher to either the new correct teacher or null.
    if (_teacher != null &&
        !_filteredTeachers.any((t) => t.id == _teacher!.id)) {
      _teacher = _filteredTeachers.firstOrNull;
    }
  }

  void _notifyParentUpdate() {
    final updatedLesson = widget.lesson.copyWith(
      subject: _subject,
      teacher: _teacher,
    );
    widget.onUpdate(updatedLesson);
  }

  @override
  Widget build(BuildContext context) {
    // Check if the lesson is null for safety, although unlikely
    if (widget.lesson.isBreak) {
      return Card(
        // Break UI (simplified)
        elevation: 0,
        color: yellowColor.withAlpha((0.3 * 255).round()),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('استراحة - ${widget.lesson.duration} دقيقة'),
        ),
      );
    }

    // Main Lesson Card UI
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: primaryGreen.withAlpha((0.3 * 255).round()),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3),
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _subject?.name ?? 'بدون مادة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Time info
            Text(
              'من ${DateFormat('HH:mm').format(widget.lesson.startTime.toDate())} إلى ${DateFormat('HH:mm').format(widget.lesson.endTime.toDate())}',
              style: TextStyle(color: secondaryText),
            ),

            const SizedBox(height: 8),

            // Subject Dropdown
            DropdownButtonFormField<SchoolSubject>(
              decoration: InputDecoration(
                filled: true,
                fillColor: textFieldFill,
                hintText: 'المادة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              initialValue: _subject,
              items: widget.allSubjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                  .toList(),
              onChanged: (s) {
                if (s != null) {
                  setState(() {
                    _subject = s;
                    _filterTeachers(s);
                    // Automatically select the first teacher for the new subject
                    _teacher = _filteredTeachers.isNotEmpty
                        ? _filteredTeachers.first
                        : null;
                    _notifyParentUpdate(); // Notify parent of change
                  });
                }
              },
            ),

            const SizedBox(height: 10),

            // Teacher Dropdown
            DropdownButtonFormField<TeacherModel>(
              decoration: InputDecoration(
                filled: true,
                fillColor: textFieldFill,
                hintText: 'المعلم',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
              initialValue: _teacher,
              items: _filteredTeachers
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.fullName, overflow: TextOverflow.ellipsis),
                    ),
                  )
                  .toList(),
              onChanged: (t) {
                setState(() {
                  _teacher = t;
                  _notifyParentUpdate(); // Notify parent of change
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
