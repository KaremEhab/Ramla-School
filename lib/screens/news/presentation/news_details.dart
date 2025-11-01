import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:ramla_school/core/app/constants.dart';
// Assuming NewsModel is here or imported via constants
import 'package:ramla_school/core/models/news_model.dart'; // Direct import if preferred

class NewsDetailsScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailsScreen({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    // Formatter for the date
    final DateFormat arabicDateFormat = DateFormat('EEEE، d MMMM y', 'ar');
    String formattedDate = arabicDateFormat.format(news.createdAt);

    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: screenBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        // --- End Shadowless AppBar ---
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'تفاصيل الخبر',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Horizontal Image Scroller
            _buildImageScroller(context),

            // 2. Content Padding
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  Text(
                    news.category,
                    style: const TextStyle(
                      color: chartOrange,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    news.title,
                    style: const TextStyle(
                      color: primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.4, // Line spacing
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date
                  Text(
                    formattedDate,
                    style: const TextStyle(color: secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Description (Body)
                  Text(
                    news.description,
                    style: const TextStyle(
                      color: secondaryText,
                      fontSize: 16,
                      height: 1.6, // Line spacing for readability
                    ),
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageScroller(BuildContext context) {
    // If no images, return an empty container or a placeholder
    if (news.images.isEmpty) {
      return Container(
        height: 220, // Same height as the scroller
        color: screenBg,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: iconGrey,
          size: 50,
        ),
      );
    }

    // 💡 ملاحظة: يجب أن تكون لديك قائمة الصور (news.images) متاحة هنا.
    // نفترض أن هذا الجزء يتم استخدامه داخل NewsCardWidget مثلاً

    if (news.images.isEmpty) {
      return const SizedBox.shrink(); // لا يوجد شيء للعرض
    }

    // ⭐️ الحالة الأولى: صورة واحدة فقط (عرض كامل)
    if (news.images.length == 1) {
      final imageUrl = news.images.first;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: AspectRatio(
            // يمكنك تعديل نسبة العرض إلى الارتفاع هنا حسب الحاجة (مثل 16/9 أو 16/10)
            aspectRatio: 16 / 10,
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              // تضمين loadingBuilder و errorBuilder
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: dividerColor,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                      color: primaryGreen,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                log("Error loading image: $error");
                return Container(
                  color: dividerColor,
                  child: const Icon(
                    Icons.error_outline,
                    color: offlineIndicator,
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // ⭐️ الحالة الثانية: أكثر من صورة واحدة (عرض أفقي)
    return SizedBox(
      height: 220, // تحديد ارتفاع منطقة الصور
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: news.images.length,
        itemBuilder: (context, index) {
          final imageUrl = news.images[index];
          return Padding(
            padding: EdgeInsets.only(
              // 💡 هنا تم تعديل الـ Padding ليناسب العرض داخل ListView
              right: index == news.images.length - 1 ? 16.0 : 8.0,
              left: index == 0 ? 16.0 : 8.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10, // نسبة العرض إلى الارتفاع للصور المتعددة
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // تضمين loadingBuilder و errorBuilder
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: dividerColor,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          color: primaryGreen,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    log("Error loading image: $error");
                    return Container(
                      color: dividerColor,
                      child: const Icon(
                        Icons.error_outline,
                        color: offlineIndicator,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
