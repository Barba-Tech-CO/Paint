import '../../domain/repository/auth_repository.dart';
import '../../model/auth_model/auth_refresh_response.dart';
import '../../model/auth_model/auth_status_response.dart';
import '../../model/user_model.dart';
import '../../service/auth_service.dart';
import '../../utils/result/result.dart';

class AuthRepository implements IAuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
    : _authService = authService;

  @override
  Future<Result<AuthStatusResponse>> getStatus() {
    return _authService.getStatus();
  }

  @override
  Future<Result<String>> getAuthorizeUrl() {
    return _authService.getAuthorizeUrl();
  }

  @override
  Future<Result<AuthRefreshResponse>> processCallback(String code) {
    return _authService.processCallback(code);
  }

  @override
  Future<Result<AuthRefreshResponse>> refreshToken() {
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

  @override
  Future<Result<String?>> getCurrentLocationId() {
    return _authService.getCurrentLocationId();
  }

  @override
  Future<Result<UserModel>> getUser() {
    return _authService.getUser();
  }
}
