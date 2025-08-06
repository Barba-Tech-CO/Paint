import 'auth_model.dart';

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
