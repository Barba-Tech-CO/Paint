class Project {
  final String id;
  final String name;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final double? estimatedValue;
  final String? clientName;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.estimatedValue,
    this.clientName,
  });
}