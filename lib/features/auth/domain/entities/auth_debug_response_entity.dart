import 'auth_debug_data_entity.dart';

class AuthDebugResponseEntity {
  final bool success;
  final AuthDebugDataEntity data;

  AuthDebugResponseEntity({
    required this.success,
    required this.data,
  });

  factory AuthDebugResponseEntity.fromJson(Map<String, dynamic> json) {
    return AuthDebugResponseEntity(
      success: json['success'] ?? false,
      data: AuthDebugDataEntity.fromJson(json['data'] ?? {}),
    );
  }
}
