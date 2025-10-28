import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/news_model.dart';
import 'package:ramla_school/core/models/users/admin_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/models/users/user_model.dart';
import 'package:ramla_school/core/widgets.dart';
import 'package:ramla_school/screens/auth/presentation/login.dart';
import 'package:ramla_school/screens/news/presentation/news.dart';
import 'package:ramla_school/screens/notifications/presentation/notifications.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // Colors based on your design
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryRed = Color(0xFFB05D5D);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color accentOrange = Color(0xFFF39C12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildCustomAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),

            // Section header
            _buildSectionHeader(
              context,
              title: 'آخر الأخبار',
              onTapSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AllNews()),
                );
              },
            ),
            const SizedBox(height: 16),

            // 📰 Dynamic News List
            ListView.builder(
              itemCount: newsList.length > 7 ? 7 : newsList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final news = newsList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: NewsCardWidget(news: news),
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Custom AppBar
  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Profile
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showProfilePopup(
                        context,
                        StudentModel(
                          id: "ST-001",
                          firstName: "ندى",
                          lastName: "احمد",
                          email: "nadaAhmed@gmail.com",
                          imageUrl:
                              'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
                          status: UserStatus.online,
                          gender: Gender.female,
                          createdAt: DateTime(2023, 1, 1),
                          grade: 6,
                          classNumber: 2,
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage:
                          "https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png"
                              .isNotEmpty
                          ? NetworkImage(
                              "https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png",
                            )
                          : const AssetImage('assets/images/boys-profile.png')
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'مرحباً',
                        style: TextStyle(color: secondaryText, fontSize: 14),
                      ),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.25,
                        child: const Text(
                          'ندى احمد',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: primaryText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Logo
            // Center(
            //   child: Image.asset('assets/images/ramla-logo.png', height: 40),
            // ),

            // 3. Notification Icon
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryGreen.withOpacity(0.1),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.notifications_none_outlined,
                      color: primaryGreen,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Notifications(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section header
  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onTapSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: onTapSeeAll,
          child: const Text(
            'المزيد',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  void _showProfilePopup(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 40,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // الصورة الشخصية
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Home.primaryGreen, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: user.imageUrl.isNotEmpty
                          ? NetworkImage(user.imageUrl)
                          : const AssetImage('assets/images/boys-profile.png')
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // الاسم الكامل
                  Text(
                    user.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Home.primaryText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // البريد الإلكتروني
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Home.secondaryText,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // بطاقة المعلومات العامة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _buildRoleSpecificInfo(user),
                        const SizedBox(height: 12),
                        _buildInfoRow('الدور', _translateRole(user.role)),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'الحالة',
                          user.status == UserStatus.online
                              ? 'متصل'
                              : 'غير متصل',
                          valueColor: user.status == UserStatus.online
                              ? Colors.green
                              : Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر تسجيل الخروج
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (context) => false,
                      ),
                      style:
                          OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(
                              color: Home.primaryRed,
                              width: 1.8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            foregroundColor: Home.primaryRed,
                            backgroundColor: Colors.transparent,
                          ).copyWith(
                            overlayColor: MaterialStateProperty.all(
                              Home.primaryRed.withOpacity(0.1),
                            ),
                          ),

                      child: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // زر الإغلاق
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'إغلاق',
                        style: TextStyle(
                          fontSize: 16,
                          color: Home.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ترجمة الدور إلى العربية
  String _translateRole(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'طالب';
      case UserRole.teacher:
        return 'معلم';
      case UserRole.admin:
        return 'مدير';
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Home.secondaryText, fontSize: 15),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Home.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // عرض بيانات خاصة حسب نوع المستخدم
  Widget _buildRoleSpecificInfo(UserModel user) {
    if (user is StudentModel) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الصف:',
                style: TextStyle(color: Home.secondaryText, fontSize: 15),
              ),
              Text(
                '${user.grade}',
                style: const TextStyle(
                  color: Home.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الفصل:',
                style: TextStyle(color: Home.secondaryText, fontSize: 15),
              ),
              Text(
                '${user.classNumber}',
                style: const TextStyle(
                  color: Home.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (user is TeacherModel) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'عدد المواد:',
            style: TextStyle(color: Home.secondaryText, fontSize: 15),
          ),
          Text(
            '${user.subjects.isNotEmpty ? user.subjects.length : 0}',
            style: const TextStyle(
              color: Home.primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ],
      );
    } else if (user is AdminModel) {
      return const Center(
        child: Text(
          'مدير النظام',
          style: TextStyle(
            color: Home.primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
