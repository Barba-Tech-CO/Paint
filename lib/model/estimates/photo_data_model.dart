class PhotoDataModel {
  final String id;
  final String filename;
  final String? originalFilename;
  final String url;
  final String? thumbnailUrl;
  final int size;
  final String mimeType;
  final String zoneId;
  final int? sequence;
  final DateTime uploadedAt;

  PhotoDataModel({
    required this.id,
    required this.filename,
    this.originalFilename,
    required this.url,
    this.thumbnailUrl,
    required this.size,
    required this.mimeType,
    required this.zoneId,
    this.sequence,
    required this.uploadedAt,
  });

  factory PhotoDataModel.fromJson(Map<String, dynamic> json) {
    return PhotoDataModel(
      id: json['id']?.toString() ?? json['uuid']?.toString() ?? '',
      filename: json['filename'] ?? '',
      originalFilename: json['original_filename'],
      url: json['url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      size: json['size'] ?? 0,
      mimeType: json['mime_type'] ?? '',
      zoneId: json['zone_id']?.toString() ?? '',
      sequence: json['sequence'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'original_filename': originalFilename,
      'url': url,
      'thumbnail_url': thumbnailUrl,
      'size': size,
      'mime_type': mimeType,
      'zone_id': zoneId,
      'sequence': sequence,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }
}
