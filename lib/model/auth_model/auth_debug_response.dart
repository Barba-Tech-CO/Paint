import 'auth_debug_data.dart';

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
