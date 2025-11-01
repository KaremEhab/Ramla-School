import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/users/admin_model.dart';
import 'package:ramla_school/core/models/users/student_model.dart';
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/models/users/user_model.dart';
import 'package:ramla_school/core/widgets.dart';
import 'package:ramla_school/screens/auth/data/login/login_cubit.dart';
import 'package:ramla_school/screens/auth/presentation/login.dart';
import 'package:ramla_school/screens/news/data/news_cubit.dart';
import 'package:ramla_school/screens/notifications/presentation/notifications.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐️ استدعاء دالة جلب الأخبار عند بناء المكون
    context.read<NewsCubit>().fetchNews();

    return Scaffold(
      backgroundColor: screenBg,
      appBar: _buildCustomAppBar(context),

      // ✅ FAB appears only for Admins
      floatingActionButton: currentRole == UserRole.admin
          ? FloatingActionButton(
              backgroundColor: primaryGreen,
              onPressed: () => _showAddNewsModal(context),
              child: const Icon(Icons.add, color: screenBg),
            )
          : null,

      // ⭐️ استخدام BlocBuilder لجلب الأخبار
      body: BlocBuilder<NewsCubit, NewsState>(
        builder: (context, state) {
          if (state is NewsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          } else if (state is NewsError) {
            return Center(
              child: Text(
                'فشل تحميل الأخبار: ${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: offlineIndicator),
              ),
            );
          } else if (state is NewsLoaded) {
            final newsList = state.newsList;
            // ⭐️ تحديد عدد العناصر المراد عرضها (15 عنصرًا كحد أقصى)
            // final displayCount = newsList.length > 15 ? 15 : newsList.length;
            final displayCount = newsList.length;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'آخر الأخبار',
                    style: const TextStyle(
                      color: primaryText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // _buildSectionHeader(
                  //   context,
                  //   title: 'آخر الأخبار',
                  //   onTapSeeAll: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //         builder: (context) => const AllNews(),
                  //       ),
                  //     );
                  //   },
                  // ),
                  const SizedBox(height: 16),

                  // ⭐️ استخدام displayCount في ListView.builder
                  ListView.builder(
                    itemCount: displayCount,
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
                  const SizedBox(height: 65),
                ],
              ),
            );
          }

          // الحالة الأولية أو حالة غير معروفة
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ✅ Bottom Sheet for Adding News (admin only)
  void _showAddNewsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for full-screen form/keyboard
      builder: (context) {
        // We wrap the modal content in a Padding or similar to ensure
        // the keyboard doesn't hide text fields.
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const AddNewsModal(),
        );
      },
    );
  }

  // --- APP BAR ---
  PreferredSizeWidget _buildCustomAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: screenBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      forceMaterialTransparency: true,
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
                      _showProfilePopup(context, currentUser!);
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
                    children: [
                      const Text(
                        'مرحباً',
                        style: TextStyle(color: secondaryText, fontSize: 14),
                      ),
                      Text(
                        currentRole == UserRole.teacher
                            ? "أ. ${currentUser?.fullName}"
                            : currentUser?.fullName ?? 'Unknown User',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
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
                    color: primaryGreen.withAlpha((0.1 * 255).round()),
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
  // Widget _buildSectionHeader(
  //   BuildContext context, {
  //   required String title,
  //   required VoidCallback onTapSeeAll,
  // }) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Text(
  //         title,
  //         style: const TextStyle(
  //           color: primaryText,
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       TextButton(
  //         onPressed: onTapSeeAll,
  //         child: const Text(
  //           'المزيد',
  //           style: TextStyle(
  //             color: primaryGreen,
  //             fontSize: 14,
  //             fontWeight: FontWeight.bold,
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
              color: screenBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.15 * 255).round()),
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
                      border: Border.all(color: primaryGreen, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: screenBg,
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
                      color: primaryText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // البريد الإلكتروني
                  Text(
                    user.email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: secondaryText),
                  ),

                  const SizedBox(height: 20),

                  // بطاقة المعلومات العامة
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: textFieldFill,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: dividerColor),
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
                              ? onlineIndicator
                              : iconGrey,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر تسجيل الخروج
                  BlocListener<LoginCubit, LoginState>(
                    listener: (context, state) {
                      if (state is LoginInitial) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const Login()),
                          (route) => false,
                        );
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<LoginCubit>().logout();
                        },
                        style:
                            OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(
                                color: offlineIndicator,
                                width: 1.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              foregroundColor: offlineIndicator,
                              backgroundColor: Colors.transparent,
                            ).copyWith(
                              overlayColor: WidgetStateProperty.all(
                                offlineIndicator.withAlpha((0.1 * 255).round()),
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
                  ),
                  const SizedBox(height: 10),

                  // زر الإغلاق
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: primaryGreen.withAlpha(
                          (0.2 * 255).round(),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'إغلاق',
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryGreen,
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
    if (user is StudentModel) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'الصف:',
                style: TextStyle(color: secondaryText, fontSize: 15),
              ),
              Text(
                '${user.grade}',
                style: const TextStyle(
                  color: primaryText,
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
                style: TextStyle(color: secondaryText, fontSize: 15),
              ),
              Text(
                '${user.classNumber}',
                style: const TextStyle(
                  color: primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (user is TeacherModel) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان وعدد المواد
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'عدد المواد:',
                style: TextStyle(color: secondaryText, fontSize: 15),
              ),
              Text(
                '${user.subjects.isNotEmpty ? user.subjects.length : 0}',
                style: const TextStyle(
                  color: primaryText,
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
                'الصف:',
                style: TextStyle(color: secondaryText, fontSize: 15),
              ),
              Text(
                user.grades.join(' - '),
                style: const TextStyle(
                  color: primaryText,
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
                      color: primaryText,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryText.withAlpha((0.2 * 255).round()),
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min, // 👈 يخلي العرض على قد المحتوى
                      children: [
                        const Icon(Icons.book, color: primaryText, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          subject.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: primaryText,
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
              style: TextStyle(color: secondaryText, fontSize: 14),
            ),
        ],
      );
    } else if (user is AdminModel) {
      return const Center(
        child: Text(
          'مدير النظام',
          style: TextStyle(
            color: primaryText,
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
