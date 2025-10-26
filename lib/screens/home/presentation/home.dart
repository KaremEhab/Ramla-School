import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/news_model.dart';
import 'package:ramla_school/screens/notifications/presentation/notifications.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // Colors based on your design
  static const Color primaryGreen = Color(0xFF5DB075);
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
                // TODO: Navigate to All News Screen
              },
            ),
            const SizedBox(height: 16),

            // 📰 Dynamic News List
            ListView.builder(
              itemCount: newsList.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final news = newsList[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: _NewsCardWidget(
                    title: news.title,
                    category: news.category,
                    imageUrl: news.images.first,
                  ),
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
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(
                      'assets/images/boys-profile.png',
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
}

// News Card Widget
class _NewsCardWidget extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;

  const _NewsCardWidget({
    required this.title,
    required this.category,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // News Image
          SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.red),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),

          // News Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: _NewsCardWidget.accentOrange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _NewsCardWidget.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const Color primaryText = Color(0xFF333333);
  static const Color accentOrange = Color(0xFFF39C12);
}
