import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/screens/home/presentation/home.dart';
import 'package:ramla_school/screens/chats/presentation/chats.dart';
import 'package:ramla_school/screens/faqs/presentation/faqs.dart';
import 'package:ramla_school/screens/timetable/presentation/timetable.dart';

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
    _pageController = PageController(initialPage: _currentIndex);
    _setupNavigationForRole(currentRole ?? UserRole.student);
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
          const TimetableScreen(),
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
          const _AdminDashboardScreen(),
          const _AnalyticsScreen(),
          const _SettingsScreen(),
        ];
        _navBarItems = [
          _buildNavItem(IconlyLight.home, IconlyBold.home, ''),
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

    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          _onNavTapped(0);
          return false;
        }

        final now = DateTime.now();
        if (_lastPressed == null ||
            now.difference(_lastPressed!) > const Duration(seconds: 2)) {
          _lastPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('اضغط رجوع مرة أخرى لإغلاق التطبيق'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }

        // Exit app
        SystemNavigator.pop();
        return true;
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
          backgroundColor: Colors.white,
          selectedItemColor: primaryGreen,
          unselectedItemColor: iconGrey,
          elevation: 0,
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

class _AdminDashboardScreen extends StatelessWidget {
  const _AdminDashboardScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('صفحة الأدمن الرئيسية')));
  }
}

class _AnalyticsScreen extends StatelessWidget {
  const _AnalyticsScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('صفحة التحليلات')));
  }
}

class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('صفحة الإعدادات')));
  }
}