import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/document_model.dart';
import 'package:ramla_school/core/models/lesson_model.dart';
import 'package:ramla_school/core/models/timetable_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/screens/documents/presentation/documents.dart';
import 'package:ramla_school/screens/timetable/data/teacher/teacher_time_table_cubit.dart';

// ------------------- MAIN SCREEN -------------------

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color unselectedDay = Color(0xFFEEEEEE);

  static const double _dayCardWidth = 60.0;
  static const double _dayCardMargin = 4.0;

  Map<DateTime, DaySchedule> _allSchedules = {};
  DateTime _selectedDate = DateTime.now();
  List<DaySchedule> _selectedMonthDays = [];
  List<TimelineEntry> _selectedDayTimeline = [];

  late ScrollController _dayScrollController;

  Map<String, List<DaySchedule>> _schedulesByMonth = {};
  String _currentMonthString = '';
  int _currentMonthIndex = 0;
  List<String> _monthKeys = [];

  @override
  void initState() {
    super.initState();
    _dayScrollController = ScrollController();
    final teacher = currentUser as TeacherModel;
    context.read<TeacherTimetableCubit>().fetchTeacherTimetables(teacher);
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  void _processFetchedData(List<TimetableModel> timetables) {
    final teacher = currentUser as TeacherModel;
    final teacherSubjects = teacher.subjects.map((s) => s.name).toList();

    final schedules = <DateTime, DaySchedule>{};

    for (final t in timetables) {
      for (int i = 0; i < t.lessons.length; i++) {
        final lesson = t.lessons[i];
        final date = DateUtils.dateOnly(lesson.startTime.toDate());

        final isMyLesson =
            lesson.teacher?.id == teacher.id ||
            teacherSubjects.contains(lesson.subject?.name);

        if (!isMyLesson) continue;

        schedules.putIfAbsent(date, () => DaySchedule(date: date, entries: []));

        if (!lesson.isBreak) {
          final subjectEnum = SchoolSubject.fromString(lesson.subject!.name);
          final color = subjectColors[subjectEnum] ?? Colors.grey.shade200;

          schedules[date]!.entries.add(
            LessonEntry(
              subject: lesson.subject!.name,
              teacher: lesson.teacher?.fullName ?? '',
              grade: t.grade.label,
              classNumber: t.classNumber.toString(),
              lessonIndex: i + 1,
              duration: '${lesson.duration} دقيقة',
              color: color,
              startTime: DateFormat(
                'hh:mm a',
              ).format(lesson.startTime.toDate()),
              endTime: DateFormat('hh:mm a').format(lesson.endTime.toDate()),
              documentUrls: lesson.documentUrls,
            ),
          );
        }
      }
    }

    // Group by months
    final Map<String, List<DaySchedule>> byMonth = {};
    final sortedDays = schedules.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    for (var day in sortedDays) {
      final monthKey = DateFormat.MMMM('ar').format(day.date);
      byMonth.putIfAbsent(monthKey, () => []);
      byMonth[monthKey]!.add(day);
    }

    // Find current date
    DateTime now = DateTime.now();
    String currentMonthKey = DateFormat.MMMM('ar').format(now);

    setState(() {
      _allSchedules = schedules;
      _schedulesByMonth = byMonth;
      _monthKeys = _schedulesByMonth.keys.toList();
      if (_monthKeys.contains(currentMonthKey)) {
        _currentMonthString = currentMonthKey;
        _currentMonthIndex = _monthKeys.indexOf(currentMonthKey);
        _selectedMonthDays = _schedulesByMonth[_currentMonthString]!;

        // If today exists in month, select it, else select first day
        if (_allSchedules.containsKey(now)) {
          _selectedDate = now;
        } else {
          _selectedDate = _selectedMonthDays.first.date;
        }
        _selectedDayTimeline = _allSchedules[_selectedDate]?.entries ?? [];
      } else if (_monthKeys.isNotEmpty) {
        _currentMonthString = _monthKeys.first;
        _currentMonthIndex = 0;
        _selectedMonthDays = _schedulesByMonth[_currentMonthString]!;
        _selectedDate = _selectedMonthDays.first.date;
        _selectedDayTimeline = _allSchedules[_selectedDate]?.entries ?? [];
      }
    });
  }

  void _onSelectDay(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedDayTimeline = _allSchedules[date]?.entries ?? [];
    });
  }

  void _onPrevMonth() {
    if (_currentMonthIndex > 0) {
      setState(() {
        _currentMonthIndex--;
        _currentMonthString = _monthKeys[_currentMonthIndex];
        _selectedMonthDays = _schedulesByMonth[_currentMonthString]!;
        _selectedDate = _selectedMonthDays.first.date;
        _selectedDayTimeline = _allSchedules[_selectedDate]?.entries ?? [];
      });
    }
  }

  void _onNextMonth() {
    if (_currentMonthIndex < _monthKeys.length - 1) {
      setState(() {
        _currentMonthIndex++;
        _currentMonthString = _monthKeys[_currentMonthIndex];
        _selectedMonthDays = _schedulesByMonth[_currentMonthString]!;
        _selectedDate = _selectedMonthDays.first.date;
        _selectedDayTimeline = _allSchedules[_selectedDate]?.entries ?? [];
      });
    }
  }

  void _onSwipeRight() {
    int currentIndex = _selectedMonthDays.indexWhere(
      (day) => DateUtils.isSameDay(day.date, _selectedDate),
    );
    if (currentIndex < _selectedMonthDays.length - 1) {
      _onSelectDay(_selectedMonthDays[currentIndex + 1].date);
    } else {
      _onNextMonth();
    }
  }

  void _onSwipeLeft() {
    int currentIndex = _selectedMonthDays.indexWhere(
      (day) => DateUtils.isSameDay(day.date, _selectedDate),
    );
    if (currentIndex > 0) {
      _onSelectDay(_selectedMonthDays[currentIndex - 1].date);
    } else {
      _onPrevMonth();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherTimetableCubit, TeacherTimetableState>(
      listener: (context, state) {
        if (state is TeacherTimetableLoaded) {
          _processFetchedData(state.timetables);
        }
      },
      builder: (context, state) {
        if (state is TeacherTimetableLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TeacherTimetableError) {
          return Center(child: Text(state.message));
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              'جدولي الدراسي للعام ${_selectedDate.year}',
              style: const TextStyle(
                color: primaryGreen,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: _allSchedules.isEmpty
              ? const Center(child: Text("لا توجد دروس"))
              : GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity != null) {
                      if (details.primaryVelocity! < 0) {
                        _onSwipeLeft();
                      } else if (details.primaryVelocity! > 0) {
                        _onSwipeRight();
                      }
                    }
                  },
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildMonthSelector(),
                      const SizedBox(height: 8),
                      _buildDaySelector(),
                      const SizedBox(height: 16),
                      Expanded(child: _buildTimeline()),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MonthArrow(
            month: _currentMonthIndex > 0
                ? _monthKeys[_currentMonthIndex - 1]
                : '',
            icon: Icons.arrow_back,
            onTap: _onPrevMonth,
            isVisible: _currentMonthIndex > 0,
          ),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: primaryText),
              const SizedBox(width: 8),
              Text(
                _currentMonthString,
                style: const TextStyle(
                  color: primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _MonthArrow(
            month: _currentMonthIndex < _monthKeys.length - 1
                ? _monthKeys[_currentMonthIndex + 1]
                : '',
            icon: Icons.arrow_forward,
            onTap: _onNextMonth,
            isVisible: _currentMonthIndex < _monthKeys.length - 1,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _dayScrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: _selectedMonthDays.map((day) {
          final isSelected = DateUtils.isSameDay(day.date, _selectedDate);
          return _DayCard(
            date: day.date,
            isSelected: isSelected,
            onTap: () => _onSelectDay(day.date),
          );
        }).toList(),
      ),
    );
  }

  // ------------------- HELPER -------------------
  String getLessonName(int lessonIndex) {
    switch (lessonIndex) {
      case 1:
        return 'الحصة الاولى';
      case 2:
        return 'الحصة الثانية';
      case 3:
        return 'استراحة اولى';
      case 4:
        return 'الحصة الثالثة';
      case 5:
        return 'الحصة الرابعة';
      case 6:
        return 'الحصة الخامسة';
      case 7:
        return 'استراحة ثانية';
      case 8:
        return 'الحصة السادسة';
      case 9:
        return 'الحصة الاخيرة';
      default:
        return 'الحصة $lessonIndex';
    }
  }

  // ------------------- BUILD TIMELINE -------------------
  Widget _buildTimeline() {
    if (_selectedDayTimeline.isEmpty) {
      return const Center(child: Text("لا توجد دروس لهذا اليوم"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _selectedDayTimeline.length,
      itemBuilder: (context, index) {
        final entry = _selectedDayTimeline[index];
        if (entry is LessonEntry) {
          return Card(
            color: primaryGreen.withAlpha((0.9 * 255).round()),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                // هذا الكود سليم كما هو، يقوم بالانتقال لصفحة الملفات
                final documents = entry.documentUrls.map((url) {
                  return DocumentModel(
                    id: url.hashCode.toString(),
                    title: 'ملف ${entry.subject}',
                    subject: entry.subject,
                    createdAt: DateTime.now(),
                    thumbnailUrl:
                        'https://cdn-icons-png.flaticon.com/512/337/337946.png', // صورة افتراضية للملف
                    documentUrl: url,
                  );
                }).toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Documents(documentUrls: documents),
                  ),
                );
              },
              textColor: Colors.white,
              title: Text(
                '${entry.subject} - ${entry.grade} / ${entry.classNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${getLessonName(entry.lessonIndex)} | ${entry.startTime} - ${entry.endTime}',
              ),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 2,
                children: [
                  Icon(IconlyLight.document, color: Colors.white),
                  const SizedBox(width: 5),
                  Text(
                    entry.documentUrls.length.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ],
              ),
            ),
          );
        } else if (entry is BreakEntry) {
          return ListTile(
            title: Text(
              entry.title,
              style: const TextStyle(
                color: _TeacherTimetableScreenState.primaryGreen,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ------------------- WIDGETS -------------------

class _MonthArrow extends StatelessWidget {
  final String month;
  final IconData icon;
  final VoidCallback onTap;
  final bool isVisible;

  const _MonthArrow({
    required this.month,
    required this.icon,
    required this.onTap,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox(width: 80);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_forward)
              Text(
                month,
                style: const TextStyle(
                  color: _TeacherTimetableScreenState.secondaryText,
                ),
              ),
            Icon(
              icon,
              color: _TeacherTimetableScreenState.secondaryText,
              size: 20,
            ),
            if (icon == Icons.arrow_back)
              Text(
                month,
                style: const TextStyle(
                  color: _TeacherTimetableScreenState.secondaryText,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCard({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String dayNumber = DateFormat.d('ar').format(date);
    String dayName = DateFormat.EEEE('ar').format(date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _TeacherTimetableScreenState._dayCardWidth,
        height: 80,
        margin: const EdgeInsets.symmetric(
          horizontal: _TeacherTimetableScreenState._dayCardMargin,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _TeacherTimetableScreenState.primaryGreen
              : _TeacherTimetableScreenState.unselectedDay,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : _TeacherTimetableScreenState.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayName,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withAlpha((0.9 * 255).round())
                    : _TeacherTimetableScreenState.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
