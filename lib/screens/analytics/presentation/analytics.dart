import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:ramla_school/screens/analytics/data/admin_analytics_cubit.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color cardBg = Colors.white;
  static const Color screenBg = Color(0xFFF8F8F8);
  static const Color chartGreen = Color(0xFF5DB075);
  static const Color chartOrange = Color(0xFFFFA500);
  static const Color chartRed = Color(0xFFDC3545);
  static const Color chartBlue = Color(0xFF007BFF);

  String arabicUnit(int count, String unit) {
    if (unit == 'طالبة') {
      if (count == 1) return 'طالبة واحدة';
      if (count == 2) return 'طالبتان';
      if (count >= 3 && count <= 10) return '$count طالبات';
      return '$count طالبة';
    } else if (unit == 'معلمة') {
      if (count == 1) return 'معلمة واحدة';
      if (count == 2) return 'معلمتان';
      if (count >= 3 && count <= 10) return '$count معلمات';
      return '$count معلمة';
    }
    return '$count $unit';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminAnalyticsCubit()..fetchAnalyticsData(),
      child: Scaffold(
        backgroundColor: screenBg,
        appBar: AppBar(
          backgroundColor: screenBg,
          elevation: 0,
          scrolledUnderElevation: 0,
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'التحليلات',
            style: TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocBuilder<AdminAnalyticsCubit, AdminAnalyticsState>(
          builder: (context, state) {
            if (state is AdminAnalyticsLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminAnalyticsFailure) {
              return Center(
                child: Text(
                  'خطأ في التحميل: ${state.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: chartRed),
                ),
              );
            }
            if (state is AdminAnalyticsLoaded) {
              final data = state.data;

              final studentVisitPercent = data.totalStudents > 0
                  ? (data.studentsVisitedToday / data.totalStudents)
                  : 0.0;
              final teacherVisitPercent = data.totalTeachers > 0
                  ? (data.teachersVisitedToday / data.totalTeachers)
                  : 0.0;

              final onlineStudents = data.studentsOnline.toDouble();
              final offlineStudents = (data.totalStudents - data.studentsOnline)
                  .toDouble();
              final onlineTeachers = data.teachersOnline.toDouble();
              final offlineTeachers = (data.totalTeachers - data.teachersOnline)
                  .toDouble();

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DailyVisitCard(
                      title: 'طالبات زارت التطبيق اليوم',
                      count: data.studentsVisitedToday,
                      total: data.totalStudents,
                      percent: studentVisitPercent,
                      unit: 'طالبة',
                      progressColor: primaryGreen,
                      arabicUnitFunc: arabicUnit,
                    ),
                    const SizedBox(height: 16),
                    _DailyVisitCard(
                      title: 'معلمات زارو التطبيق اليوم',
                      count: data.teachersVisitedToday,
                      total: data.totalTeachers,
                      percent: teacherVisitPercent,
                      unit: 'معلمة',
                      progressColor: chartBlue,
                      arabicUnitFunc: arabicUnit,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            count: data.studentsOnline,
                            label: 'طالبة متصلة الان',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _StatCard(
                            count: data.teachersOnline,
                            label: 'معلمة متصلة الان',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // 3. Weekly Analytics Title
                    const Text(
                      'التحليلات على مدار الاسبوع',
                      style: TextStyle(
                        color: primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Weekly Chart Card
                    _WeeklyChartCard(
                      onlineStudents: onlineStudents,
                      offlineStudents: offlineStudents,
                      onlineTeachers: onlineTeachers,
                      offlineTeachers: offlineTeachers,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

class _DailyVisitCard extends StatelessWidget {
  final String title;
  final int count;
  final int total;
  final double percent;
  final String unit;
  final Color progressColor;
  final String Function(int, String) arabicUnitFunc;

  const _DailyVisitCard({
    required this.title,
    required this.count,
    required this.total,
    required this.percent,
    required this.unit,
    required this.progressColor,
    required this.arabicUnitFunc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AnalyticsScreen.cardBg,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AnalyticsScreen.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${arabicUnitFunc(count, unit)} من أصل $total',
                  style: const TextStyle(
                    color: AnalyticsScreen.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    /* TODO: Implement details view */
                  },
                  child: const Text(
                    'عرض التفاصيل',
                    style: TextStyle(
                      color: AnalyticsScreen.primaryGreen,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: AnalyticsScreen.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircularPercentIndicator(
            radius: 40.0,
            lineWidth: 8.0,
            percent: percent.clamp(0.0, 1.0),
            center: Text(
              "${(percent.clamp(0.0, 1.0) * 100).toStringAsFixed(0)}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: progressColor,
              ),
            ),
            progressColor: progressColor,
            backgroundColor: progressColor.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;

  const _StatCard({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AnalyticsScreen.cardBg,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              color: AnalyticsScreen.primaryGreen,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AnalyticsScreen.secondaryText,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  final double onlineStudents;
  final double offlineStudents;
  final double onlineTeachers;
  final double offlineTeachers;

  const _WeeklyChartCard({
    required this.onlineStudents,
    required this.offlineStudents,
    required this.onlineTeachers,
    required this.offlineTeachers,
  });

  @override
  Widget build(BuildContext context) {
    // Total users for pie chart calculation
    final total =
        onlineStudents + offlineStudents + onlineTeachers + offlineTeachers;

    final sections = [
      // Students Online (Green)
      if (onlineStudents > 0)
        PieChartSectionData(
          color: AnalyticsScreen.chartGreen,
          value: total == 0 ? 0 : (onlineStudents / total) * 100,
          title: '',
          radius: 35,
        ),
      // Students Offline (Red)
      if (offlineStudents > 0)
        PieChartSectionData(
          color: AnalyticsScreen.chartRed,
          value: total == 0 ? 0 : (offlineStudents / total) * 100,
          title: '',
          radius: 35,
        ),
      // Teachers Online (Orange)
      if (onlineTeachers > 0)
        PieChartSectionData(
          color: AnalyticsScreen.chartOrange,
          value: total == 0 ? 0 : (onlineTeachers / total) * 100,
          title: '',
          radius: 35,
        ),
      // Teachers Offline (Blue)
      if (offlineTeachers > 0)
        PieChartSectionData(
          color: AnalyticsScreen.chartBlue,
          value: total == 0 ? 0 : (offlineTeachers / total) * 100,
          title: '',
          radius: 35,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AnalyticsScreen.cardBg,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 3. Weekly Analytics Title - Moved here to be inside the card, more compact
          const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              'حالة اتصال المستخدمين',
              style: TextStyle(
                color: AnalyticsScreen.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                startDegreeOffset: -90,
                sections: sections,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runSpacing: 12.0,
            spacing: 16.0,
            children: [
              _buildLegendItem(AnalyticsScreen.chartGreen, 'طلاب متصلين'),
              _buildLegendItem(AnalyticsScreen.chartRed, 'طلاب غير متصلين'),
              _buildLegendItem(AnalyticsScreen.chartOrange, 'معلمين متصلين'),
              _buildLegendItem(AnalyticsScreen.chartBlue, 'معلمين غير متصلين'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AnalyticsScreen.secondaryText,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
