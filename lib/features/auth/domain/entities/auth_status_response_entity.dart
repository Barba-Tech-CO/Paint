import 'auth_entity.dart';

class AuthStatusResponseEntity {
  final bool success;
  final AuthEntity data;

  AuthStatusResponseEntity({
    required this.success,
    required this.data,
  });

  factory AuthStatusResponseEntity.fromJson(Map<String, dynamic> json) {
    return AuthStatusResponseEntity(
      success: json['success'] ?? false,
      data: AuthEntity.fromJson(json['data'] ?? {}),
    );
  }
}
