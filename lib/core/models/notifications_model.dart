class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String timeAgo;
  final String imageUrl; // Placeholder image URL
  final bool isNew;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.imageUrl,
    this.isNew = false,
  });
}
