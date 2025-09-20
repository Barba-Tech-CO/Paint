class PdfUploadInfo {
  final int id;
  final String originalName;
  final String? displayName;
  final DateTime createdAt;

  PdfUploadInfo({
    required this.id,
    required this.originalName,
    this.displayName,
    required this.createdAt,
  });

  factory PdfUploadInfo.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    final requiredFields = ['id', 'original_name', 'created_at'];

    for (final field in requiredFields) {
      if (json[field] == null) {
        throw Exception('Missing required field: $field');
      }
    }

    return PdfUploadInfo(
      id: json['id'] as int,
      originalName: json['original_name'] as String,
      displayName: json['display_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_name': originalName,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
