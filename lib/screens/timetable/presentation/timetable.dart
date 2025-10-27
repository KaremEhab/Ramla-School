import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/document_model.dart';
import 'package:ramla_school/screens/documents/presentation/documents.dart';
import 'package:ramla_school/screens/timetable/data/fake_timetable.dart';

// ------------------- DATA MODELS -------------------

abstract class TimelineEntry {
  final String startTime;
  final String endTime;
  const TimelineEntry({required this.startTime, required this.endTime});
}

class LessonEntry extends TimelineEntry {
  final String subject;
  final String teacher;
  final String duration;
  final Color color;
  final List<String> documentUrls; // 👈 new field

  const LessonEntry({
    required this.subject,
    required this.teacher,
    required this.duration,
    required this.color,
    required super.startTime,
    required super.endTime,
    this.documentUrls = const [],
  });
}

class BreakEntry extends TimelineEntry {
  final String title;
  const BreakEntry({
    required this.title,
    required super.startTime,
    required super.endTime,
  });
}

class DaySchedule {
  final DateTime date;
  final List<TimelineEntry> entries;

  DaySchedule({required this.date, required this.entries});
}

// ------------------- MAIN SCREEN -------------------

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  // ---------------- COLORS ----------------
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color unselectedDay = Color(0xFFEEEEEE);

  // ---------------- DAY CARD DIMENSIONS ----------------
  static const double _dayCardWidth = 60.0;
  static const double _dayCardMargin = 4.0;

  // ---------------- STATE VARIABLES ----------------
  late Map<DateTime, DaySchedule> _allSchedules;
  late DateTime _selectedDate;
  late DateTime _currentDisplayMonth;
  late int _firstLessonYear;

  List<DaySchedule> _daysForCurrentMonth = [];
  List<TimelineEntry> _selectedDayTimeline = [];
  String _currentMonthString = '';

  late ScrollController _dayScrollController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _dayScrollController = ScrollController();

    // Load mock data
    final mockList = MockTimetableService.generateOctoberTimetables();
    _allSchedules = {
      for (final t in mockList)
        DateUtils.dateOnly(t.date): DaySchedule(
          date: t.date,
          entries: t.lessons.map((l) {
            if (l.isBreak) {
              return BreakEntry(
                title: (l.isBreak ? l.breakTitle : ''),
                startTime: DateFormat('hh:mm a').format(l.startTime.toDate()),
                endTime: DateFormat('hh:mm a').format(l.endTime.toDate()),
              );
            } else {
              return LessonEntry(
                subject: l.subject!.name,
                teacher: l.teacher?.fullName ?? '',
                duration: '${l.duration} دقيقة',
                startTime: DateFormat('hh:mm a').format(l.startTime.toDate()),
                endTime: DateFormat('hh:mm a').format(l.endTime.toDate()),
                color: Colors
                    .primaries[Random().nextInt(Colors.primaries.length)]
                    .shade100,
                documentUrls: l.documentUrls, // 👈 add this
              );
            }
          }).toList(),
        ),
    };

    if (_allSchedules.isEmpty) {
      _initializeEmptyState();
    } else {
      _initializeWithData();
    }

    _pageController = PageController(
      initialPage: _daysForCurrentMonth.indexWhere(
        (d) => DateUtils.isSameDay(d.date, _selectedDate),
      ),
    );
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _initializeEmptyState() {
    DateTime now = DateTime.now();
    _currentDisplayMonth = DateTime(now.year, now.month, 1);
    _firstLessonYear = now.year;
    _selectedDate = now;
    _daysForCurrentMonth = [];
    _selectedDayTimeline = [];
    _currentMonthString = DateFormat.MMMM('ar').format(_currentDisplayMonth);
  }

  void _initializeWithData() {
    _firstLessonYear = _allSchedules.keys.map((d) => d.year).reduce(min);

    DateTime now = DateTime.now();
    DateTime initialSelectedDate = now;

    if (now.weekday == DateTime.friday) {
      initialSelectedDate = now.subtract(const Duration(days: 1));
    } else if (now.weekday == DateTime.saturday) {
      initialSelectedDate = now.add(const Duration(days: 1));
    }

    // Ensure selected date exists in schedule
    if (_allSchedules.isNotEmpty) {
      DateTime firstDataDate = _allSchedules.keys.reduce(
        (a, b) => a.isBefore(b) ? a : b,
      );
      if (initialSelectedDate.isBefore(firstDataDate)) {
        initialSelectedDate = firstDataDate;
      }

      while (initialSelectedDate.weekday == DateTime.friday ||
          initialSelectedDate.weekday == DateTime.saturday) {
        initialSelectedDate = initialSelectedDate.add(const Duration(days: 1));
        if (initialSelectedDate.isAfter(_allSchedules.keys.last)) {
          initialSelectedDate = firstDataDate;
          while (initialSelectedDate.weekday == DateTime.friday ||
              initialSelectedDate.weekday == DateTime.saturday) {
            initialSelectedDate = initialSelectedDate.add(
              const Duration(days: 1),
            );
          }
          break;
        }
      }
    }

    _selectedDate = DateUtils.dateOnly(initialSelectedDate);
    _currentDisplayMonth = DateTime(
      initialSelectedDate.year,
      initialSelectedDate.month,
      1,
    );

    // Populate days for the current month and selected day's timeline
    _updateMonthData(scrollToSelected: true);

    // Initialize the PageController AFTER updating month data
    int initialPage = _daysForCurrentMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, _selectedDate),
    );
    if (initialPage < 0) initialPage = 0;

    _pageController = PageController(initialPage: initialPage);
  }

  void _updateMonthData({
    bool selectFirstDay = false,
    bool scrollToSelected = false,
  }) {
    setState(() {
      _currentMonthString = DateFormat.MMMM('ar').format(_currentDisplayMonth);

      _daysForCurrentMonth = _allSchedules.values
          .where(
            (s) =>
                s.date.year == _currentDisplayMonth.year &&
                s.date.month == _currentDisplayMonth.month &&
                s.entries.isNotEmpty,
          )
          .toList();

      _daysForCurrentMonth.sort((a, b) => a.date.compareTo(b.date));

      DateTime targetDate = _selectedDate;

      if (_daysForCurrentMonth.isNotEmpty) {
        if (selectFirstDay ||
            !_daysForCurrentMonth.any(
              (d) => DateUtils.isSameDay(d.date, _selectedDate),
            )) {
          targetDate = _daysForCurrentMonth.first.date;
        }
      } else {
        targetDate = DateTime(
          _currentDisplayMonth.year,
          _currentDisplayMonth.month,
          1,
        );
      }

      _selectedDate = DateUtils.dateOnly(targetDate);
      _selectedDayTimeline =
          _allSchedules[DateUtils.dateOnly(_selectedDate)]?.entries ?? [];
    });

    if (scrollToSelected && _daysForCurrentMonth.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDay();
      });
    }
  }

  void _scrollToSelectedDay() {
    if (!_dayScrollController.hasClients || _daysForCurrentMonth.isEmpty)
      return;

    int selectedIndex = _daysForCurrentMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, _selectedDate),
    );

    if (selectedIndex != -1) {
      double screenWidth = MediaQuery.of(context).size.width;
      double cardWidthWithMargin = _dayCardWidth + (_dayCardMargin * 2);

      double targetOffset =
          (selectedIndex * cardWidthWithMargin) +
          (cardWidthWithMargin / 2) -
          (screenWidth / 2);

      targetOffset = targetOffset.clamp(
        _dayScrollController.position.minScrollExtent,
        _dayScrollController.position.maxScrollExtent,
      );

      _dayScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onDaySelected(DateTime date) {
    int pageIndex = _daysForCurrentMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, date),
    );

    if (pageIndex == -1) return; // safety

    setState(() {
      _selectedDate = DateUtils.dateOnly(date);
      _selectedDayTimeline =
          _allSchedules[DateUtils.dateOnly(date)]?.entries ?? [];
    });

    // Animate PageView to that day's page
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  void _onPrevMonth() {
    if (_currentDisplayMonth.year == _firstLessonYear &&
        _currentDisplayMonth.month == 1)
      return;

    setState(() {
      _currentDisplayMonth = DateTime(
        _currentDisplayMonth.year,
        _currentDisplayMonth.month - 1,
        1,
      );
    });
    _updateMonthData(selectFirstDay: true, scrollToSelected: true);
  }

  void _onNextMonth() {
    if (_allSchedules.isNotEmpty) {
      DateTime lastDate = _allSchedules.keys.reduce(
        (a, b) => a.isAfter(b) ? a : b,
      );
      if (_currentDisplayMonth.year == lastDate.year &&
          _currentDisplayMonth.month == lastDate.month)
        return;
    }

    setState(() {
      _currentDisplayMonth = DateTime(
        _currentDisplayMonth.year,
        _currentDisplayMonth.month + 1,
        1,
      );
    });
    _updateMonthData(selectFirstDay: true, scrollToSelected: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildMonthSelector(),
          const SizedBox(height: 24),
          _buildDaySelector(),
          const SizedBox(height: 32),
          _buildTimeline(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false, // 👈 disables the back button
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'الجدول الدراسي ${_currentDisplayMonth.year}',
        style: const TextStyle(
          color: _TimetableScreenState.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    String prevMonth = DateFormat.MMMM('ar').format(
      DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month - 1),
    );
    String nextMonth = DateFormat.MMMM('ar').format(
      DateTime(_currentDisplayMonth.year, _currentDisplayMonth.month + 1),
    );

    bool canGoBack =
        !(_currentDisplayMonth.year == _firstLessonYear &&
            _currentDisplayMonth.month == 1);
    bool canGoForward = true;
    if (_allSchedules.isNotEmpty) {
      DateTime lastDate = _allSchedules.keys.reduce(
        (a, b) => a.isAfter(b) ? a : b,
      );
      canGoForward =
          !(_currentDisplayMonth.year == lastDate.year &&
              _currentDisplayMonth.month == lastDate.month);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MonthArrow(
            month: prevMonth,
            icon: Icons.arrow_back,
            onTap: _onPrevMonth,
            isVisible: canGoBack,
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
            month: nextMonth,
            icon: Icons.arrow_forward,
            onTap: _onNextMonth,
            isVisible: canGoForward,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    if (_daysForCurrentMonth.isEmpty) {
      return Container(
        height: 80,
        alignment: Alignment.center,
        child: const Text(
          'لا توجد دروس مجدولة في هذا الشهر',
          style: TextStyle(color: secondaryText, fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      controller: _dayScrollController,
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: _daysForCurrentMonth.map((day) {
            bool isSelected = DateUtils.isSameDay(day.date, _selectedDate);
            return _DayCard(
              date: day.date,
              isSelected: isSelected,
              onTap: () => _onDaySelected(day.date),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    if (_daysForCurrentMonth.isEmpty) {
      bool isWeekend =
          _selectedDate.weekday == DateTime.friday ||
          _selectedDate.weekday == DateTime.saturday;
      return Expanded(
        child: Center(
          child: Text(
            isWeekend ? 'يوم عطلة' : 'لا توجد دروس لهذا اليوم',
            style: const TextStyle(color: secondaryText, fontSize: 16),
          ),
        ),
      );
    }

    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _daysForCurrentMonth.length,
        onPageChanged: (index) {
          setState(() {
            _selectedDate = _daysForCurrentMonth[index].date;
            _selectedDayTimeline = _daysForCurrentMonth[index].entries;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSelectedDay();
          });
        },
        itemBuilder: (context, index) {
          final dayTimeline = _daysForCurrentMonth[index].entries;

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: dayTimeline.length,
            itemBuilder: (context, i) {
              final entry = dayTimeline[i];
              if (entry is LessonEntry) {
                return _TimeSlot(
                  time: entry.startTime,
                  child: _LessonCard(lesson: entry),
                );
              } else if (entry is BreakEntry) {
                return _TimeSlot(
                  time: entry.startTime,
                  child: _BreakIndicator(breakInfo: entry),
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

// ------------------- HELPER WIDGETS -------------------

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
                  color: _TimetableScreenState.secondaryText,
                ),
              ),
            Icon(icon, color: _TimetableScreenState.secondaryText, size: 20),
            if (icon == Icons.arrow_back)
              Text(
                month,
                style: const TextStyle(
                  color: _TimetableScreenState.secondaryText,
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
        width: _TimetableScreenState._dayCardWidth,
        height: 80,
        margin: const EdgeInsets.symmetric(
          horizontal: _TimetableScreenState._dayCardMargin,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? _TimetableScreenState.primaryGreen
              : _TimetableScreenState.unselectedDay,
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
                    : _TimetableScreenState.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayName,
              style: TextStyle(
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : _TimetableScreenState.secondaryText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  final String time;
  final Widget child;

  const _TimeSlot({required this.time, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                time,
                style: const TextStyle(
                  color: _TimetableScreenState.secondaryText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _BreakIndicator extends StatelessWidget {
  final BreakEntry breakInfo;
  const _BreakIndicator({required this.breakInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: _TimetableScreenState.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),
          const Expanded(
            child: Divider(
              color: _TimetableScreenState.primaryGreen,
              thickness: 2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            breakInfo.title,
            style: const TextStyle(
              color: _TimetableScreenState.primaryGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final LessonEntry lesson;
  const _LessonCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: lesson.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // هذا الكود سليم كما هو، يقوم بالانتقال لصفحة الملفات
          final documents = lesson.documentUrls.map((url) {
            return DocumentModel(
              id: url.hashCode.toString(),
              title: 'ملف ${lesson.subject}',
              subject: lesson.subject,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // ✅ (إضافة) ضمان محاذاة العناصر العلوية للعمودين
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- الجهة اليسرى (العنوان والأستاذ) ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.subject,
                      style: const TextStyle(
                        color: _TimetableScreenState.primaryText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.teacher,
                      style: const TextStyle(
                        color: _TimetableScreenState.secondaryText,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // --- الجهة اليمنى (المدة والملفات) ---
              // ✅ (تعديل) حولنا النص إلى عمود ليحمل المدة + صف الملفات
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min, // ليأخذ العمود أصغر حجم ممكن
                children: [
                  // 1. المدة (45 دقيقة)
                  Text(
                    lesson.duration,
                    style: const TextStyle(
                      color: _TimetableScreenState.secondaryText,
                      fontSize: 14,
                    ),
                  ),

                  // 2. (إضافة) صف الملفات - يظهر فقط لو فيه ملفات
                  if (lesson.documentUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0), // مسافة علوية
                      child: Row(
                        spacing: 4,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${lesson.documentUrls.length}', // عدد الملفات
                            style: const TextStyle(
                              color: _TimetableScreenState.secondaryText,
                              fontSize: 18,
                              height: 1.0,

                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            IconlyLight.document, // أيقونة الملف
                            color: _TimetableScreenState.secondaryText,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
