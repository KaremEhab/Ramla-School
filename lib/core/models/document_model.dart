class DocumentModel {
  final String id;
  final String title;
  final String subject;
  final DateTime createdAt;
  final String thumbnailUrl;
  final String documentUrl;

  DocumentModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.createdAt,
    required this.thumbnailUrl,
    required this.documentUrl,
  });
}
