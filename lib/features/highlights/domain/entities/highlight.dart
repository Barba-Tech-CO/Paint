class Highlight {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime createdAt;
  final bool isPriority;
  final String? imageUrl;
  final String? actionUrl;

  const Highlight({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.createdAt,
    this.isPriority = false,
    this.imageUrl,
    this.actionUrl,
  });
}