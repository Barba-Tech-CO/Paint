class AuthModel {
  final bool authenticated;
  final DateTime? expiresAt;
  final bool needsLogin;
  final String? locationId;

  AuthModel({
    required this.authenticated,
    this.expiresAt,
    required this.needsLogin,
    this.locationId,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
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

class AuthStatusResponse {
  final bool success;
  final AuthModel data;

  AuthStatusResponse({
    required this.success,
    required this.data,
  });

  factory AuthStatusResponse.fromJson(Map<String, dynamic> json) {
    return AuthStatusResponse(
      success: json['success'] ?? false,
      data: AuthModel.fromJson(json['data'] ?? {}),
    );
  }
}

class AuthRefreshResponse {
  final bool success;
  final DateTime expiresAt;

  AuthRefreshResponse({
    required this.success,
    required this.expiresAt,
  });

  factory AuthRefreshResponse.fromJson(Map<String, dynamic> json) {
    return AuthRefreshResponse(
      success: json['success'] ?? false,
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}

class AuthDebugResponse {
  final bool success;
  final AuthDebugData data;

  AuthDebugResponse({
    required this.success,
    required this.data,
  });

  factory AuthDebugResponse.fromJson(Map<String, dynamic> json) {
    return AuthDebugResponse(
      success: json['success'] ?? false,
      data: AuthDebugData.fromJson(json['data'] ?? {}),
    );
  }
}

class AuthDebugData {
  final int totalTokens;
  final int valid;
  final int expired;

  AuthDebugData({
    required this.totalTokens,
    required this.valid,
    required this.expired,
  });

  factory AuthDebugData.fromJson(Map<String, dynamic> json) {
    return AuthDebugData(
      totalTokens: json['total_tokens'] ?? 0,
      valid: json['valid'] ?? 0,
      expired: json['expired'] ?? 0,
    );
  }
}
