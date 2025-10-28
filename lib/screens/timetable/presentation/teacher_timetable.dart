import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/document_model.dart';
import 'package:ramla_school/screens/documents/presentation/documents.dart';
import 'package:ramla_school/screens/timetable/data/fake_teacher_timetable.dart';
import 'timetable.dart'; // يحتوي على النماذج (LessonEntry, BreakEntry, DaySchedule...)

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

  late Map<DateTime, DaySchedule> _teacherSchedules;
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  late PageController _pageController;
  late ScrollController _dayScrollController;

  List<DaySchedule> _daysForMonth = [];
  List<TimelineEntry> _selectedDayEntries = [];
  String _monthName = '';

  final String _teacherName = "أ. سارة";

  @override
  void initState() {
    super.initState();
    _dayScrollController = ScrollController();

    final mockList = MockTeacherTimetableService.generateTeacherTimetables();
    _teacherSchedules = {};

    // 🟢 استخراج الجدول الخاص بالمعلمة
    for (final t in mockList) {
      if (t.lessons.any(
        (l) => l.teacher?.fullName.trim() == _teacherName.trim(),
      )) {
        final lessons = t.lessons
            .where(
              (l) =>
                  !l.isBreak &&
                  l.teacher?.fullName.trim() == _teacherName.trim(),
            )
            .map(
              (l) => LessonEntry(
                subject: _translateSubject(l.subject!.name),
                teacher: l.teacher?.fullName ?? '',
                duration: '${l.duration} دقيقة',
                startTime: DateFormat(
                  'hh:mm a',
                  'ar',
                ).format(l.startTime.toDate()),
                endTime: DateFormat('hh:mm a', 'ar').format(l.endTime.toDate()),
                color: Colors
                    .primaries[Random().nextInt(Colors.primaries.length)]
                    .shade100,
                documentUrls: l.documentUrls,
                extraInfo:
                    'الصف ${_translateGrade(t.grade.name)} / ${t.classNumber}',
              ),
            )
            .toList();

        _teacherSchedules[DateUtils.dateOnly(t.date)] = DaySchedule(
          date: t.date,
          entries: lessons,
        );
      }
    }

    _initData();

    // ✅ Scroll to today after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelectedDay());
  }

  void _initData() {
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _monthName = DateFormat.MMMM('ar').format(_currentMonth);

    _daysForMonth =
        _teacherSchedules.values
            .where(
              (d) =>
                  d.date.year == _currentMonth.year &&
                  d.date.month == _currentMonth.month &&
                  d.entries.isNotEmpty,
            )
            .toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    _selectedDate = _teacherSchedules.keys.contains(DateUtils.dateOnly(now))
        ? DateUtils.dateOnly(now)
        : (_daysForMonth.isNotEmpty ? _daysForMonth.first.date : _currentMonth);

    _selectedDayEntries =
        _teacherSchedules[DateUtils.dateOnly(_selectedDate)]?.entries ?? [];

    final initialPage = _daysForMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, _selectedDate),
    );

    _pageController = PageController(
      initialPage: initialPage >= 0 ? initialPage : 0,
    );
  }

  void _onDaySelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedDayEntries =
          _teacherSchedules[DateUtils.dateOnly(date)]?.entries ?? [];
    });

    final index = _daysForMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, _selectedDate),
    );
    if (index >= 0) {
      _pageController.jumpToPage(index);
      _scrollToSelectedDay();
    }
  }

  void _scrollToSelectedDay() {
    final index = _daysForMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, _selectedDate),
    );
    if (index >= 0 && _dayScrollController.hasClients) {
      const double itemWidth = 72;
      final offset = (index * itemWidth) - 120;
      _dayScrollController.animateTo(
        offset.clamp(0, _dayScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: false, // ✅ prevents scroll under AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'جدولي الدراسي',
          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        color: Colors.white, // ✅ background stays white
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildMonthHeader(),
            const SizedBox(height: 16),
            Container(
              color: Colors.white, // ✅ ensure white under days
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildDaySelector(),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildTimeline()), // ✅ timeline stays below
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.calendar_month_outlined, color: primaryText),
        const SizedBox(width: 8),
        Text(
          _monthName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    if (_daysForMonth.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'لا توجد دروس في هذا الشهر',
          style: TextStyle(color: secondaryText, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: _dayScrollController,
      child: Row(
        children: _daysForMonth.map((day) {
          final isSelected = DateUtils.isSameDay(day.date, _selectedDate);
          final dayNumber = DateFormat.d('ar').format(day.date);
          final dayName = DateFormat.EEEE('ar').format(day.date);

          return GestureDetector(
            onTap: () => _onDaySelected(day.date),
            child: Container(
              width: 60,
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryGreen : unselectedDay,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNumber,
                    style: TextStyle(
                      color: isSelected ? Colors.white : primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dayName,
                    style: TextStyle(
                      color: isSelected ? Colors.white : secondaryText,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimeline() {
    if (_daysForMonth.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد دروس لعرضها',
          style: TextStyle(color: secondaryText, fontSize: 16),
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      itemCount: _daysForMonth.length,
      onPageChanged: (i) {
        setState(() {
          _selectedDate = _daysForMonth[i].date;
          _selectedDayEntries = _daysForMonth[i].entries;
        });
        _scrollToSelectedDay();
      },
      itemBuilder: (context, i) {
        final lessons = _daysForMonth[i].entries;
        if (lessons.isEmpty) {
          return const Center(child: Text('لا توجد دروس في هذا اليوم'));
        }

        return Container(
          color: Colors.white, // ✅ ensures no background bleed
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final entry = lessons[index];
              if (entry is LessonEntry) {
                return _TeacherLessonCard(lesson: entry);
              }
              return const SizedBox.shrink();
            },
          ),
        );
      },
    );
  }

  /// 🈯 ترجمة أسماء المواد
  String _translateSubject(String subject) {
    switch (subject) {
      case 'math':
        return 'الرياضيات';
      case 'science':
        return 'العلوم';
      case 'fitness':
        return 'اللياقة';
      case 'music':
        return 'الموسيقى';
      case 'islamic':
        return 'التربية الإسلامية';
      case 'computer':
        return 'الحاسب الآلي';
      case 'geography':
        return 'الجغرافيا';
      case 'english':
        return 'اللغة الإنجليزية';
      case 'arabic':
        return 'اللغة العربية';
      case 'houseEconomics':
        return 'الاقتصاد المنزلي';
      case 'practicalStudies':
        return 'الدراسات العملية';
      case 'art':
        return 'الفنون';
      default:
        return subject;
    }
  }

  /// 🎓 ترجمة الصفوف الدراسية
  String _translateGrade(String grade) {
    switch (grade) {
      case 'grade1':
        return 'الأول';
      case 'grade2':
        return 'الثاني';
      case 'grade3':
        return 'الثالث';
      case 'grade4':
        return 'الرابع';
      case 'grade5':
        return 'الخامس';
      case 'grade6':
        return 'السادس';
      case 'grade7':
        return 'السابع';
      case 'grade8':
        return 'الثامن';
      case 'grade9':
        return 'التاسع';
      default:
        return grade;
    }
  }
}

class _TeacherLessonCard extends StatelessWidget {
  final LessonEntry lesson;
  const _TeacherLessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: () {
          final documents = lesson.documentUrls.map((url) {
            return DocumentModel(
              id: url.hashCode.toString(),
              title: 'ملف ${lesson.subject}',
              subject: lesson.subject,
              createdAt: DateTime.now(),
              thumbnailUrl:
                  'https://cdn-icons-png.flaticon.com/512/337/337946.png',
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
        tileColor: lesson.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        title: Text(
          lesson.subject,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: _TeacherTimetableScreenState.primaryText,
          ),
        ),
        subtitle: Text(
          "${lesson.startTime} - ${lesson.endTime}\n${lesson.extraInfo}",
          style: const TextStyle(
            color: _TeacherTimetableScreenState.secondaryText,
          ),
        ),
        trailing: lesson.documentUrls.isNotEmpty
            ? const Icon(Icons.folder_open, color: Colors.black54)
            : null,
      ),
    );
  }
}
