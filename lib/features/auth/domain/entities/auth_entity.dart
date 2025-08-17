class AuthEntity {
  final bool authenticated;
  final DateTime? expiresAt;
  final bool needsLogin;
  final String? locationId;

  AuthEntity({
    required this.authenticated,
    this.expiresAt,
    required this.needsLogin,
    this.locationId,
  });

  factory AuthEntity.fromJson(Map<String, dynamic> json) {
    return AuthEntity(
      authenticated: json['authenticated'] ?? false,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      needsLogin: json['needs_login'] ?? true,
      locationId: json['location_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authenticated': authenticated,
      'expires_at': expiresAt?.toIso8601String(),
      'needs_login': needsLogin,
      'location_id': locationId,
    };
  }
}
