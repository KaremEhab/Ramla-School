import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Import percent_indicator
import 'package:fl_chart/fl_chart.dart'; // Import fl_chart

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color cardBg = Colors.white;
  static const Color screenBg = Color(0xFFF8F8F8); // Light grey background
  static const Color chartGreen = Colors.green; // Example
  static const Color chartOrange = Colors.orange; // Example
  static const Color chartRed = Colors.red; // Example
  static const Color chartBlue = Colors.lightBlue; // Example


  // --- Mock Data ---
  final int totalStudents = 230;
  final int studentsVisitedToday = 123;
  final int totalTeachers = 100;
  final int teachersVisitedToday = 23;
  final int studentsOnline = 56;
  final int teachersOnline = 22;


  @override
  Widget build(BuildContext context) {
    double studentVisitPercent = (studentsVisitedToday / totalStudents);
    double teacherVisitPercent = (teachersVisitedToday / totalTeachers);

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: screenBg, // Match screen background
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false, // No back button
        // --- End Shadowless AppBar ---
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Daily Visits Cards
            _DailyVisitCard(
              title: 'طلاب زارو التطبيق اليوم',
              count: studentsVisitedToday,
              total: totalStudents,
              percent: studentVisitPercent,
              unit: 'طالبة',
              progressColor: primaryGreen,
            ),
            const SizedBox(height: 16),
            _DailyVisitCard(
              title: 'معلمين زارو التطبيق اليوم',
              count: teachersVisitedToday,
              total: totalTeachers,
              percent: teacherVisitPercent,
              unit: 'معلمة',
              progressColor: Colors.blue, // Different color for teachers
            ),
            const SizedBox(height: 24),

            // 2. Online Stats Cards (Only Students and Teachers Online)
            Row(
              children: [
                 Expanded(
                   child: _StatCard(
                     count: studentsOnline,
                     label: 'طالب متصل الان',
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: _StatCard(
                     count: teachersOnline,
                     label: 'معلم متصل الان',
                   ),
                 ),
              ],
            ),
            // The other two cards ("عدد الطلاب المسجلين", "تحميل ملفاتك") are removed as requested.
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
              // Pass mock data or fetch dynamically
              activeStudents: 0.6, // 60%
              inactiveStudents: 0.15, // 15%
              activeTeachers: 0.1, // 10%
              inactiveTeachers: 0.15, // 15%
            ),
             const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }
}

// --- Helper Widgets ---

// Card for Daily Visits with Progress Circle
class _DailyVisitCard extends StatelessWidget {
  final String title;
  final int count;
  final int total;
  final double percent;
  final String unit;
  final Color progressColor;

  const _DailyVisitCard({
    required this.title,
    required this.count,
    required this.total,
    required this.percent,
    required this.unit,
    required this.progressColor,
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
          )
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
                  '$count $unit من اصل $total $unit',
                  style: const TextStyle(
                    color: AnalyticsScreen.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () { /* TODO: Implement details view */ },
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
            percent: percent,
            center: Text(
              "${(percent * 100).toStringAsFixed(0)}%",
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

// Card for Simple Stat Counts
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
          )
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


// Card for the Weekly Donut Chart and Legend
class _WeeklyChartCard extends StatelessWidget {
    final double activeStudents;
    final double inactiveStudents;
    final double activeTeachers;
    final double inactiveTeachers;

  const _WeeklyChartCard({
    required this.activeStudents,
    required this.inactiveStudents,
    required this.activeTeachers,
    required this.inactiveTeachers,
    });

  @override
  Widget build(BuildContext context) {
     // Ensure percentages add up roughly to 1.0 for PieChart, adjust if needed
    final total = activeStudents + inactiveStudents + activeTeachers + inactiveTeachers;
    // Normalize if total is not 1 (or close enough)
    final normActiveStudents = total == 0 ? 0.25 : activeStudents / total;
    final normInactiveStudents = total == 0 ? 0.25 : inactiveStudents / total;
    final normActiveTeachers = total == 0 ? 0.25 : activeTeachers / total;
    final normInactiveTeachers = total == 0 ? 0.25 : inactiveTeachers / total;


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
           )
         ],
       ),
      child: Column(
        children: [
          SizedBox(
            height: 180, // Height for the chart
            child: PieChart(
              PieChartData(
                sectionsSpace: 4, // Space between sections
                centerSpaceRadius: 50, // Radius of the center hole
                startDegreeOffset: -90, // Start from the top
                sections: [
                   PieChartSectionData(
                     color: AnalyticsScreen.chartGreen,
                     value: normActiveStudents * 100, // Use normalized value
                     title: '', // No title on section
                     radius: 35,
                   ),
                   PieChartSectionData(
                     color: AnalyticsScreen.chartRed,
                     value: normInactiveStudents * 100,
                     title: '',
                     radius: 35,
                   ),
                    PieChartSectionData(
                     color: AnalyticsScreen.chartOrange,
                     value: normActiveTeachers * 100,
                     title: '',
                     radius: 35,
                   ),
                    PieChartSectionData(
                     color: AnalyticsScreen.chartBlue, // Added a blue for inactive teachers
                     value: normInactiveTeachers * 100,
                     title: '',
                     radius: 35,
                   ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Legend
          Wrap( // Use Wrap for better responsiveness if labels get long
             alignment: WrapAlignment.spaceEvenly,
             runSpacing: 12.0, // Space between rows if Wrap needs multiple lines
             spacing: 16.0,   // Space between items horizontally
             children: [
               _buildLegendItem(AnalyticsScreen.chartGreen, 'طلاب نشيطين'),
               _buildLegendItem(AnalyticsScreen.chartRed, 'طلاب غير نشيطين'),
               _buildLegendItem(AnalyticsScreen.chartOrange, 'معلمين نشيطين'),
               _buildLegendItem(AnalyticsScreen.chartBlue, 'معلمين غير نشيطين'), // Added legend item
             ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Take only needed space
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
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