import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/widgets.dart';

class AllNews extends StatelessWidget {
  const AllNews({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBg,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: screenBg,
        elevation: 0, // No shadow
        scrolledUnderElevation: 0, // No shadow when scrolling
        // --- End Shadowless AppBar ---
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'آخر الأخبار',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: newsList.length,
        itemBuilder: (context, index) {
          final news = newsList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: NewsCardWidget(news: news),
          );
        },
      ),
    );
  }
}
