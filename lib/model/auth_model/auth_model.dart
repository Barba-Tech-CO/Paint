class AuthModel {
  final bool authenticated;
  final DateTime? expiresAt;
  final bool needsLogin;
  final String? locationId;
  final int? expiresInMinutes;
  final bool? isExpiringSoon;

  AuthModel({
    required this.authenticated,
    this.expiresAt,
    required this.needsLogin,
    this.locationId,
    this.expiresInMinutes,
    this.isExpiringSoon,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      authenticated: json['authenticated'] ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      needsLogin: json['needs_login'] ?? true,
      locationId: json['location_id'],
      expiresInMinutes: json['expires_in_minutes'],
      isExpiringSoon: json['is_expiring_soon'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authenticated': authenticated,
      'expires_at': expiresAt?.toIso8601String(),
      'needs_login': needsLogin,
      'location_id': locationId,
      'expires_in_minutes': expiresInMinutes,
      'is_expiring_soon': isExpiringSoon,
    };
  }
}
