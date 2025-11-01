import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/screens/home/presentation/home.dart';
import 'package:ramla_school/screens/chats/presentation/chats.dart';
import 'package:ramla_school/screens/faqs/presentation/faqs.dart';
import 'package:ramla_school/screens/analytics/presentation/analytics.dart';
import 'package:ramla_school/screens/timetable/presentation/admin_timetable.dart';
import 'package:ramla_school/screens/timetable/presentation/teacher_timetable.dart';
import 'package:ramla_school/screens/settings/presentation/settings.dart';
import 'package:ramla_school/screens/timetable/presentation/student_timetable.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  DateTime? _lastPressed;

  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navBarItems = [];

  // Colors
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color iconGrey = Color(0xFFAAAAAA);

  @override
  void initState() {
    super.initState();
    log("---------- accessToken: $accessToken ----------");
    log("---------- fcmDeviceToken: $fcmDeviceToken ----------");
    _pageController = PageController(initialPage: _currentIndex);
    _setupNavigationForRole(currentRole ?? UserRole.teacher);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Configures the pages and navbar items based on the user's role
  void _setupNavigationForRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        _pages = [
          const Home(),
          const TimetableScreen(),
          const MessagesScreen(),
          const FaqsScreen(),
        ];
        _navBarItems = [
          _buildNavItem(IconlyLight.home, IconlyBold.home, ''),
          _buildNavItem(IconlyLight.calendar, IconlyBold.calendar, ''),
          _buildNavItem(IconlyLight.message, IconlyBold.message, ''),
          _buildNavItem(IconlyLight.info_circle, IconlyBold.info_circle, ''),
        ];
        break;
      case UserRole.teacher:
        _pages = [
          const Home(),
          const TeacherTimetableScreen(),
          const MessagesScreen(),
          const _MyClassScreen(),
        ];
        _navBarItems = [
          _buildNavItem(IconlyLight.home, IconlyBold.home, ''),
          _buildNavItem(IconlyLight.calendar, IconlyBold.calendar, ''),
          _buildNavItem(IconlyLight.message, IconlyBold.message, ''),
          _buildNavItem(Icons.people_outline, Icons.people, ''),
        ];
        break;
      case UserRole.admin:
        _pages = [
          const Home(),
          const AdminTimetablePage(),
          const AnalyticsScreen(),
          const AdminSettingsScreen(),
        ];
        _navBarItems = [
          _buildNavItem(IconlyLight.home, IconlyBold.home, ''),
          _buildNavItem(IconlyLight.calendar, IconlyBold.calendar, ''),
          _buildNavItem(Icons.analytics_outlined, Icons.analytics, ''),
          _buildNavItem(IconlyLight.setting, IconlyBold.setting, ''),
        ];
        break;
    }
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Icon(activeIcon),
      label: label,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (_currentIndex != 0) {
          _onNavTapped(0);
          return; // Action handled: navigated to the first tab.
        }

        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          // First tap or time has elapsed: show message and record time
          _lastPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('اضغط رجوع مرة أخرى لإغلاق التطبيق'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // Second tap within 2 seconds: Exit app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onNavTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: screenBg,
          selectedItemColor: primaryGreen,
          unselectedItemColor: iconGrey,
          elevation: 1,
          items: _navBarItems,
        ),
      ),
    );
  }
}

// --- PLACEHOLDER SCREENS ---

class _MyClassScreen extends StatelessWidget {
  const _MyClassScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('صفحة فصلي')));
  }
}
