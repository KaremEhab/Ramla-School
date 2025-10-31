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

      // ✅ FAB appears only for Admins
      floatingActionButton: currentRole == UserRole.admin
          ? FloatingActionButton(
              backgroundColor: primaryGreen,
              onPressed: () => _showAddNewsModal(context),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ListView(
          children: [
            const SizedBox(height: 24),
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

  // ✅ Bottom Sheet for Adding News (admin only)
  void _showAddNewsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _adminAddNewsSheet(context),
    );
  }

  // 🧩 Admin modal
  Widget _adminAddNewsSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "إضافة خبر جديد",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'عنوان الخبر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'تفاصيل الخبر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.image_outlined),
              label: const Text("رفع صورة"),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت إضافة الخبر بنجاح!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'إضافة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- APP BAR ---
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
            // Profile
            Expanded(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _showProfilePopup(
                        context,
                        currentRole == UserRole.admin
                            ? AdminModel(
                                id: "AD-001",
                                firstName: "كريم",
                                lastName: "ايهاب",
                                email: "admin@ramla.com",
                                imageUrl:
                                    "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                status: UserStatus.online,
                                gender: Gender.male,
                                createdAt: DateTime.now(),
                              )
                            : currentRole == UserRole.teacher
                            ? TeacherModel(
                                id: "T-001",
                                firstName: "أ. سارة",
                                lastName: "علاء",
                                email: "sara@example.com",
                                imageUrl:
                                    "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                status: UserStatus.online,
                                gender: Gender.female,
                                createdAt: DateTime.now(),
                                subjects: [
                                  SchoolSubject.computer,
                                  SchoolSubject.science,
                                ],
                              )
                            : StudentModel(
                                id: "ST-001",
                                firstName: "ندى",
                                lastName: "محمد",
                                email: "nada@example.com",
                                imageUrl:
                                    "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                status: UserStatus.online,
                                gender: Gender.female,
                                createdAt: DateTime.now(),
                                grade: 6,
                                classNumber: 2,
                              ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'مرحباً',
                        style: TextStyle(color: secondaryText, fontSize: 14),
                      ),
                      Text(
                        'كريم ايهاب',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Notification Icon
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

  // --- Shared Widgets ---
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

  // --- Profile Dialog ---
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

  // عرض بيانات خاصة حسب نوع المستخدم
  Widget _buildRoleSpecificInfo(UserModel user) {
    if (user.role == UserRole.student && user is StudentModel) {
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
    } else if (user.role == UserRole.teacher && user is TeacherModel) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان وعدد المواد
          Row(
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
          ),
          const SizedBox(height: 8),

          // عرض قائمة المواد
          if (user.subjects.isNotEmpty)
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: user.subjects.length,
                itemBuilder: (context, index) {
                  final subject = user.subjects[index];

                  return Container(
                    margin: EdgeInsets.only(right: index == 0 ? 0 : 5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ), // 👈 padding بدل width ثابت
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Home.primaryText.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // 👈 يخلي العرض على قد المحتوى
                      children: [
                        const Icon(
                          Icons.book,
                          color: Home.primaryText,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subject.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Home.primaryText,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            const Text(
              'لا توجد مواد مضافة بعد.',
              style: TextStyle(color: Home.secondaryText, fontSize: 14),
            ),
        ],
      );
    } else if (user.role == UserRole.admin && user is AdminModel) {
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

  // --- Utilities ---
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
        Text(label, style: const TextStyle(color: secondaryText, fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? primaryText,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
