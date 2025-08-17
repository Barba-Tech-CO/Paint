import '../../domain/repository/auth_repository.dart';
import '../../features/auth/infrastructure/services/auth_service_impl.dart';
import '../../features/auth/domain/entities/auth_status_response_entity.dart';
import '../../features/auth/domain/entities/auth_refresh_response_entity.dart';
import '../../utils/result/result.dart';

class AuthRepository implements IAuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
    : _authService = authService;

  @override
  Future<Result<AuthStatusResponseEntity>> getStatus() {
    return _authService.getStatus();
  }

  @override
  Future<Result<String>> getAuthorizeUrl() {
    return _authService.getAuthorizeUrl();
  }

  @override
  Future<Result<AuthRefreshResponseEntity>> processCallback(String code) {
    return _authService.processCallback(code);
  }

  @override
  Future<Result<AuthRefreshResponseEntity>> refreshToken() {
    return _authService.refreshToken();
  }

  @override
  Future<Result<bool>> isAuthenticated() {
    return _authService.isAuthenticated();
  }

  @override
  Future<Result<bool>> isTokenExpiringSoon() {
    return _authService.isTokenExpiringSoon();
  }
}
