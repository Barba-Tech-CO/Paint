class AuthRefreshResponse {
  final bool success;
  final DateTime? expiresAt;
  final String? locationId;
  final String? sanctumToken;
  final String? message;

  AuthRefreshResponse({
    required this.success,
    this.expiresAt,
    this.locationId,
    this.sanctumToken,
    this.message,
  });

  factory AuthRefreshResponse.fromJson(Map<String, dynamic> json) {
    return AuthRefreshResponse(
      success: json['success'] ?? false,
      expiresAt: json['expires_at'] != null && json['expires_at'] is String
          ? DateTime.tryParse(json['expires_at'])
          : null,
      locationId: json['location_id'],
      sanctumToken: json['sanctum_token'],
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'expires_at': expiresAt?.toIso8601String(),
      'location_id': locationId,
      'sanctum_token': sanctumToken,
      'message': message,
    };
  }
}
