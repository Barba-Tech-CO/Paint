class AuthRefreshResponse {
  final bool success;
  final DateTime? expiresAt;
  final String? locationId;
  final String? sanctumToken;
  final String? message;
  final String? authToken;
  final bool? syncInitiated;

  AuthRefreshResponse({
    required this.success,
    this.expiresAt,
    this.locationId,
    this.sanctumToken,
    this.message,
    this.authToken,
    this.syncInitiated,
  });

  factory AuthRefreshResponse.fromJson(Map<String, dynamic> json) {
    // Try different possible token field names
    final String? extractedAuthToken = json['auth_token'] as String? ?? 
                                      json['token'] as String? ?? 
                                      json['access_token'] as String? ?? 
                                      json['bearer_token'] as String?;
    
    return AuthRefreshResponse(
      success: json['success'] ?? false,
      expiresAt: json['expires_at'] != null && json['expires_at'] is String
          ? DateTime.tryParse(json['expires_at'])
          : null,
      locationId: json['location_id'],
      sanctumToken: json['sanctum_token'],
      message: json['message'],
      authToken: extractedAuthToken,
      syncInitiated: json['sync_initiated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'expires_at': expiresAt?.toIso8601String(),
      'location_id': locationId,
      'sanctum_token': sanctumToken,
      'message': message,
      'auth_token': authToken,
      'sync_initiated': syncInitiated,
    };
  }
}
