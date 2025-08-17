class AuthDebugDataEntity {
  final int totalTokens;
  final int valid;
  final int expired;

  AuthDebugDataEntity({
    required this.totalTokens,
    required this.valid,
    required this.expired,
  });

  factory AuthDebugDataEntity.fromJson(Map<String, dynamic> json) {
    return AuthDebugDataEntity(
      totalTokens: json['total_tokens'] ?? 0,
      valid: json['valid'] ?? 0,
      expired: json['expired'] ?? 0,
    );
  }
}
