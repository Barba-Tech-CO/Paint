class AuthRefreshResponseEntity {
  final bool success;
  final DateTime? expiresAt;

  AuthRefreshResponseEntity({
    required this.success,
    this.expiresAt,
  });

  factory AuthRefreshResponseEntity.fromJson(Map<String, dynamic> json) {
    return AuthRefreshResponseEntity(
      success: json['success'] ?? false,
      expiresAt: json['expires_at'] != null && json['expires_at'] is String
          ? DateTime.tryParse(json['expires_at'])
          : null,
    );
  }
}
