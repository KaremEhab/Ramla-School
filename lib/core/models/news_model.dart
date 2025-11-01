class NewsModel {
  final String id; // Firestore document ID
  final String title;
  final String category;
  final String description;
  final DateTime createdAt;
  final List<String> images;

  NewsModel({
    this.id = '', // default empty
    required this.title,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.images,
  });

  /// Create a copy of this NewsModel with optional new values
  NewsModel copyWith({
    String? id,
    String? title,
    String? category,
    String? description,
    DateTime? createdAt,
    List<String>? images,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? List<String>.from(this.images),
    );
  }

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
