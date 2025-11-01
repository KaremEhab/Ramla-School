import 'dart:developer';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconly/iconly.dart';
import 'package:intl/intl.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/document_model.dart';
import 'package:ramla_school/core/models/lesson_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/screens/documents/presentation/documents.dart';
import 'package:ramla_school/screens/timetable/data/student/student_time_table_cubit.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color unselectedDay = Color(0xFFEEEEEE);

  static const double _dayCardWidth = 60.0;
  static const double _dayCardMargin = 4.0;

  Map<DateTime, DaySchedule> _allSchedules = {};
  late DateTime _selectedDate;
  late DateTime _currentDisplayMonth;
  late int firstLessonYear;

  List<DaySchedule> _daysForCurrentMonth = [];
  List<TimelineEntry> selectedDayTimeline = [];
  String currentMonthString = '';

  late ScrollController _dayScrollController;
  late PageController _pageController;
  List<DateTime> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _dayScrollController = ScrollController();
    _selectedDate = DateTime.now();
    _currentDisplayMonth = DateTime(_selectedDate.year, _selectedDate.month);
    firstLessonYear = _selectedDate.year;
    _pageController = PageController();

    final user = currentUser as StudentModel;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentTimetableCubit>().fetchStudentTimetable(
        user.grade,
        user.classNumber,
      );
    });
  }

  @override
  void dispose() {
    _dayScrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ---------- DATA UPDATES ----------
  void _updateMonthData({
    bool selectFirstDay = false,
    bool scrollToSelected = false,
  }) {
    setState(() {
      currentMonthString = DateFormat.MMMM('ar').format(_currentDisplayMonth);
      _daysForCurrentMonth =
          _allSchedules.values
              .where(
                (s) =>
                    s.date.year == _currentDisplayMonth.year &&
                    s.date.month == _currentDisplayMonth.month,
              )
              .toList()
            ..sort((a, b) => a.date.compareTo(b.date));

      DateTime targetDate = _selectedDate;

      if (_daysForCurrentMonth.isNotEmpty) {
        if (selectFirstDay ||
            !_daysForCurrentMonth.any(
              (d) => DateUtils.isSameDay(d.date, _selectedDate),
            )) {
          targetDate = _daysForCurrentMonth.first.date;
        }
      }

      _selectedDate = DateUtils.dateOnly(targetDate);
      selectedDayTimeline =
          _allSchedules[DateUtils.dateOnly(_selectedDate)]?.entries ?? [];
    });

    if (scrollToSelected && _daysForCurrentMonth.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedDay();
      });
    }
  }

  void _scrollToSelectedDay() {
    if (!_dayScrollController.hasClients || _daysForCurrentMonth.isEmpty) {
      return;
    }

    int index = _daysForCurrentMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, _selectedDate),
    );
    if (index == -1) return;

    double width = MediaQuery.of(context).size.width;
    double cardWidth = _dayCardWidth + (_dayCardMargin * 2);
    double targetOffset = (index * cardWidth) + (cardWidth / 2) - (width / 2);

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

  // ---------- MONTH SWITCH ----------

  void onPrevMonth() {
    // ابحث عن أقرب شهر سابق فيه بيانات فعلًا
    DateTime? prevAvailableMonth = _findAdjacentMonth(isNext: false);

    if (prevAvailableMonth == null) {
      log('⚠️ لا يوجد شهر سابق يحتوي على جدول.');
      return; // لا ننتقل لو مفيش بيانات
    }

    setState(() {
      _currentDisplayMonth = prevAvailableMonth;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMonthData(scrollToSelected: true);
      if (_daysForCurrentMonth.isNotEmpty) {
        setState(() {
          _selectedDate = _daysForCurrentMonth.last.date;
          selectedDayTimeline = _allSchedules[_selectedDate]?.entries ?? [];
        });
        _pageController.jumpToPage(_daysForCurrentMonth.length - 1);
        _scrollToSelectedDay();
      }
    });
  }

  void onNextMonth() {
    // ابحث عن أقرب شهر لاحق فيه بيانات فعلًا
    DateTime? nextAvailableMonth = _findAdjacentMonth(isNext: true);

    if (nextAvailableMonth == null) {
      log('⚠️ لا يوجد شهر لاحق يحتوي على جدول.');
      return; // لا ننتقل لو مفيش بيانات
    }

    setState(() {
      _currentDisplayMonth = nextAvailableMonth;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateMonthData(scrollToSelected: true);
      if (_daysForCurrentMonth.isNotEmpty) {
        setState(() {
          _selectedDate = _daysForCurrentMonth.first.date;
          selectedDayTimeline = _allSchedules[_selectedDate]?.entries ?? [];
        });
        _pageController.jumpToPage(0);
        _scrollToSelectedDay();
      }
    });
  }

  // ---------------------- SWIPE FUNCTIONS ----------------------

  void _onSwipeRight() {
    int currentIndex = _daysForCurrentMonth.indexWhere(
      (day) => DateUtils.isSameDay(day.date, _selectedDate),
    );

    if (currentIndex < _daysForCurrentMonth.length - 1) {
      _onDaySelected(_daysForCurrentMonth[currentIndex + 1].date);
    } else {
      // لو وصلنا لنهاية الشهر، نحاول ننتقل للشهر التالي لو فيه بيانات
      DateTime? nextAvailableMonth = _findAdjacentMonth(isNext: true);
      if (nextAvailableMonth != null) onNextMonth();
    }
  }

  void _onSwipeLeft() {
    int currentIndex = _daysForCurrentMonth.indexWhere(
      (day) => DateUtils.isSameDay(day.date, _selectedDate),
    );

    if (currentIndex > 0) {
      _onDaySelected(_daysForCurrentMonth[currentIndex - 1].date);
    } else {
      // لو في بداية الشهر، نحاول ننتقل للشهر السابق لو فيه بيانات
      DateTime? prevAvailableMonth = _findAdjacentMonth(isNext: false);
      if (prevAvailableMonth != null) onPrevMonth();
    }
  }

  // ---------------------- HELPER FUNCTION ----------------------

  // تبحث عن أقرب شهر فيه بيانات سواء التالي أو السابق
  DateTime? _findAdjacentMonth({required bool isNext}) {
    if (_allSchedules.isEmpty) return null;

    // استخراج كل الشهور اللي فيها بيانات
    final availableMonths =
        _allSchedules.keys
            .map((d) => DateTime(d.year, d.month))
            .toSet()
            .toList()
          ..sort((a, b) => a.compareTo(b));

    DateTime currentMonth = DateTime(
      _currentDisplayMonth.year,
      _currentDisplayMonth.month,
    );

    if (isNext) {
      for (final m in availableMonths) {
        if (m.isAfter(currentMonth)) return m;
      }
    } else {
      for (final m in availableMonths.reversed) {
        if (m.isBefore(currentMonth)) return m;
      }
    }

    return null; // مفيش شهر متاح
  }

  // ---------- BLOC LISTENER ----------
  @override
  Widget build(BuildContext context) {
    return BlocListener<StudentTimetableCubit, StudentTimetableState>(
      listener: (context, state) {
        if (state is StudentTimetableLoaded) {
          final timetables = state.timetables;
          _allSchedules = {
            for (final t in timetables)
              DateUtils.dateOnly(t.date): DaySchedule(
                date: t.date,
                entries: t.lessons.map((l) {
                  if (l.isBreak) {
                    return BreakEntry(
                      title: l.breakTitle ?? '',
                      startTime: DateFormat(
                        'hh:mm a',
                      ).format(l.startTime.toDate()),
                      endTime: DateFormat('hh:mm a').format(l.endTime.toDate()),
                    );
                  } else {
                    return LessonEntry(
                      subject: l.subject!.name,
                      teacher: l.teacher?.fullName ?? '',
                      grade: t.grade.label,
                      classNumber: t.classNumber.toString(),
                      lessonIndex: t.lessons.indexOf(l) + 1,
                      duration: '${l.duration} دقيقة',
                      color: Colors
                          .primaries[math.Random().nextInt(
                            Colors.primaries.length,
                          )]
                          .shade100,
                      startTime: DateFormat(
                        'hh:mm a',
                      ).format(l.startTime.toDate()),
                      endTime: DateFormat('hh:mm a').format(l.endTime.toDate()),
                      documentUrls: l.documentUrls,
                    );
                  }
                }).toList(),
              ),
          };

          final uniqueMonths =
              _allSchedules.keys
                  .map((d) => DateTime(d.year, d.month))
                  .toSet()
                  .toList()
                ..sort((a, b) => a.compareTo(b));
          _availableMonths = uniqueMonths;
          _initializeWithData();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: GestureDetector(
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
              _buildMonthSelector(),
              const SizedBox(height: 24),
              _buildDaySelector(),
              const SizedBox(height: 32),
              _buildTimeline(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- INIT ----------
  void _initializeWithData() {
    if (_availableMonths.isEmpty) return;
    if (!_availableMonths.any(
      (m) =>
          m.year == _currentDisplayMonth.year &&
          m.month == _currentDisplayMonth.month,
    )) {
      _currentDisplayMonth = _availableMonths.first;
    }
    _selectedDate = _allSchedules.keys.first;
    _updateMonthData(scrollToSelected: true);
    int index = _daysForCurrentMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, _selectedDate),
    );
    if (index < 0) index = 0;
    _pageController = PageController(initialPage: index);
  }

  // ---------- UI BUILDERS ----------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        'الجدول الدراسي ${_currentDisplayMonth.year}',
        style: const TextStyle(
          color: primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildMonthSelector() {
    int currentIndex = _availableMonths.indexWhere(
      (m) =>
          m.year == _currentDisplayMonth.year &&
          m.month == _currentDisplayMonth.month,
    );

    String currentMonth = DateFormat.MMMM('ar').format(_currentDisplayMonth);
    String? prevMonth = currentIndex > 0
        ? DateFormat.MMMM('ar').format(_availableMonths[currentIndex - 1])
        : null;
    String? nextMonth = currentIndex < _availableMonths.length - 1
        ? DateFormat.MMMM('ar').format(_availableMonths[currentIndex + 1])
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MonthArrow(
            month: prevMonth ?? '',
            icon: Icons.arrow_back,
            onTap: onPrevMonth,
            isVisible: prevMonth != null,
          ),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: primaryText),
              const SizedBox(width: 8),
              Text(
                currentMonth,
                style: const TextStyle(
                  color: primaryText,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          _MonthArrow(
            month: nextMonth ?? '',
            icon: Icons.arrow_forward,
            onTap: onNextMonth,
            isVisible: nextMonth != null,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    if (_daysForCurrentMonth.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: Text(
            'لا توجد دروس في هذا الشهر',
            style: TextStyle(color: secondaryText, fontSize: 16),
          ),
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
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _daysForCurrentMonth.length,
        itemBuilder: (context, index) {
          final entries = _daysForCurrentMonth[index].entries;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final entry = entries[i];
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

  void _onDaySelected(DateTime date) {
    int idx = _daysForCurrentMonth.indexWhere(
      (d) => DateUtils.isSameDay(d.date, date),
    );
    if (idx == -1) return;
    setState(() {
      _selectedDate = DateUtils.dateOnly(date);
      selectedDayTimeline =
          _allSchedules[DateUtils.dateOnly(date)]?.entries ?? [];
    });
    _pageController.jumpToPage(idx);
    _scrollToSelectedDay();
  }
}

// ---------- HELPERS ----------
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
                    ? Colors.white.withAlpha((0.9 * 255).round())
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
            child: Text(
              time,
              style: const TextStyle(
                color: _TimetableScreenState.secondaryText,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
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
              builder: (_) => Documents(documentUrls: documents),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lesson.duration,
                    style: const TextStyle(
                      color: _TimetableScreenState.secondaryText,
                      fontSize: 14,
                    ),
                  ),
                  if (lesson.documentUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Text(
                            '${lesson.documentUrls.length}',
                            style: const TextStyle(
                              color: _TimetableScreenState.secondaryText,
                              fontSize: 18,
                              height: 1.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(
                            IconlyLight.document,
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
