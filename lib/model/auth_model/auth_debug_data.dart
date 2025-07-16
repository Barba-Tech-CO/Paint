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
