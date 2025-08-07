class AuthRefreshResponse {
  final bool success;
  final DateTime? expiresAt;

  AuthRefreshResponse({
    required this.success,
    this.expiresAt,
  });

  factory AuthRefreshResponse.fromJson(Map<String, dynamic> json) {
    return AuthRefreshResponse(
      success: json['success'] ?? false,
      expiresAt: json['expires_at'] != null && json['expires_at'] is String
          ? DateTime.tryParse(json['expires_at'])
          : null,
    );
  }
}
