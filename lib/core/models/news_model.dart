class NewsModel {
  final String title;
  final String category;
  final String description;
  final DateTime createdAt;
  final List<String> images;

  NewsModel({
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.images,
  });

  // Factory constructor for converting from JSON (useful for APIs/Firebase)
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  // Convert to JSON (useful for uploading to backend)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'images': images,
    };
  }
}
