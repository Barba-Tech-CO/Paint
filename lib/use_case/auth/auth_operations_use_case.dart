import '../../model/auth_model.dart';
import '../../service/auth_service.dart';
import '../../utils/result/result.dart';

/// UseCase unificado para todas as operações de autenticação
class AuthOperationsUseCase {
  final AuthService _authService;

  AuthOperationsUseCase(this._authService);

  /// Verifica o status de autenticação
  Future<Result<AuthModel>> checkAuthStatus() async {
    try {
      final result = await _authService.getStatus();
      return result.when(
        ok: (status) {
          return Result.ok(status.data);
        },
        error: (error) {
          return Result.error(error);
        },
      );
    } catch (error, stackTrace) {
      return Result.error(Exception(error.toString()));
    }
  }

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl() async {
    return await _authService.getAuthorizeUrl();
  }

  /// Processa o callback de autorização
  Future<Result<void>> processCallback(String code) async {
    final result = await _authService.processCallback(code);
    return result.when(
      ok: (response) => Result.ok(null),
      error: (error) => Result.error(error),
    );
  }

  /// Renova o token de acesso
  Future<Result<void>> refreshToken() async {
    final result = await _authService.refreshToken();
    return result.when(
      ok: (response) => Result.ok(null),
      error: (error) => Result.error(error),
    );
  }

  /// Verifica se o token está próximo de expirar
  Future<Result<bool>> isTokenExpiringSoon() async {
    return await _authService.isTokenExpiringSoon();
  }
}
