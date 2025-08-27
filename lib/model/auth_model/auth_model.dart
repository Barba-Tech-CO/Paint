class AuthModel {
  final bool authenticated;
  final DateTime? expiresAt;
  final bool needsLogin;
  final String? locationId;
  final int? expiresInMinutes;
  final bool? isExpiringSoon;
  final int? expiresIn;
  final bool? tokenValid;
  final String? sanctumToken;

  AuthModel({
    required this.authenticated,
    this.expiresAt,
    required this.needsLogin,
    this.locationId,
    this.expiresInMinutes,
    this.isExpiringSoon,
    this.expiresIn,
    this.tokenValid,
    this.sanctumToken,
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
      expiresIn: json['expires_in'],
      tokenValid: json['token_valid'],
      sanctumToken: json['auth_token'],
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
      'expires_in': expiresIn,
      'token_valid': tokenValid,
      'auth_token': sanctumToken,
    };
  }

  AuthModel copyWith({
    bool? authenticated,
    DateTime? expiresAt,
    bool? needsLogin,
    String? locationId,
    int? expiresInMinutes,
    bool? isExpiringSoon,
    int? expiresIn,
    bool? tokenValid,
    String? sanctumToken,
  }) {
    return AuthModel(
      authenticated: authenticated ?? this.authenticated,
      expiresAt: expiresAt ?? this.expiresAt,
      needsLogin: needsLogin ?? this.needsLogin,
      locationId: locationId ?? this.locationId,
      expiresInMinutes: expiresInMinutes ?? this.expiresInMinutes,
      isExpiringSoon: isExpiringSoon ?? this.isExpiringSoon,
      expiresIn: expiresIn ?? this.expiresIn,
      tokenValid: tokenValid ?? this.tokenValid,
      sanctumToken: sanctumToken ?? this.sanctumToken,
    );
  }
}
