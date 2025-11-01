import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
// Assuming NewsModel is here or imported via constants
import 'package:ramla_school/core/models/news_model.dart'; // Direct import if preferred

class NewsDetailsScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailsScreen({super.key, required this.news});

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color accentOrange = Color(0xFFF39C12); // Category color
  static const Color imagePlaceholderBg = Color(0xFFEEEEEE);

  @override
  Widget build(BuildContext context) {
    // Formatter for the date
    final DateFormat arabicDateFormat = DateFormat('EEEE، d MMMM y', 'ar');
    String formattedDate = arabicDateFormat.format(news.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: Colors.white,
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
                      color: accentOrange,
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
        color: imagePlaceholderBg,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: Colors.grey,
          size: 50,
        ),
      );
    }

    return SizedBox(
      height: 220, // Define a height for the image area
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: news.images.length,
        itemBuilder: (context, index) {
          final imageUrl = news.images[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index == 0 ? 16.0 : 8.0, // Start padding
              left: index == news.images.length - 1 ? 16.0 : 8.0, // End padding
              top: 8.0,
              bottom: 8.0,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10, // Adjust aspect ratio as needed
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // Add loading and error builders for robustness
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: imagePlaceholderBg,
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
                    print("Error loading image: $error"); // Log error
                    return Container(
                      color: imagePlaceholderBg,
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
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
