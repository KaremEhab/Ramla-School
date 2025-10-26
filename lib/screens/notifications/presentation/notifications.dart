import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/notifications_model.dart';

class Notifications extends StatelessWidget {
  const Notifications({super.key});

  // --- Colors (Sampled from image) ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color newNotificationBg = Color(
    0xFFD7F5E2,
  ); // Light green background
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color accentOrange = Color(0xFFF39C12);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: Colors.white,
        elevation: 0, // No shadow
        scrolledUnderElevation: 0, // No shadow when scrolling
        // --- End Shadowless AppBar ---
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'الاشعارات',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Padding(
            // Add space between cards
            padding: const EdgeInsets.only(bottom: 12.0),
            child: _NotificationCard(notification: notification),
          );
        },
      ),
    );
  }
}

// --- Notification Card Widget ---
class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    // Determine background color based on 'isNew'
    final Color backgroundColor = notification.isNew
        ? Notifications.newNotificationBg
        : Colors.white; // Or a very light grey like Colors.grey[50]

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20.0),
        // Add a subtle border for non-new items if needed
        border: notification.isNew
            ? null
            : Border.all(color: Colors.grey[200]!),
        boxShadow: notification.isNew
            ? [
                // Optional subtle shadow for new items
                BoxShadow(
                  color: Notifications.primaryGreen.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Icon / Image with Badge
          Stack(
            clipBehavior: Clip.none, // Allow badge to overflow
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: NetworkImage(notification.imageUrl),
                backgroundColor: Colors.grey[200], // Fallback color
              ),
              if (notification.isNew)
                Positioned(
                  top: -5,
                  right: -5, // In RTL, right is correct for top-left visual
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Notifications.accentOrange,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '1', // Or fetch count dynamically
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16), // Space between image and text
          // 2. Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(
                    color: Notifications.primaryText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.body,
                  style: const TextStyle(
                    color: Notifications.secondaryText,
                    fontSize: 14,
                    height: 1.4, // Adjust line spacing if needed
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.timeAgo,
                  style: const TextStyle(
                    color: Notifications.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
