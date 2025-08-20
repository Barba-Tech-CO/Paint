import '../../model/auth_model.dart';
import '../../service/auth_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

/// UseCase unificado para todas as operações de autenticação
class AuthOperationsUseCase {
  final AuthService _authService;
  final AppLogger _logger;

  AuthOperationsUseCase(this._authService, this._logger);

  /// Verifica o status de autenticação
  Future<Result<AuthModel>> checkAuthStatus() async {
    _logger.info('checkAuthStatus');

    try {
      final result = await _authService.getStatus();
      return result.when(
        ok: (status) {
          _logger.info(
            'checkAuthStatus_success - status: ${status.data.toString()}',
          );
          return Result.ok(status.data);
        },
        error: (error) {
          _logger.error(
            'AuthOperationsUseCase.checkAuthStatus error',
            error,
          );
          return Result.error(error);
        },
      );
    } catch (error, stackTrace) {
      _logger.error(
        'AuthOperationsUseCase.checkAuthStatus exception',
        error,
        stackTrace,
      );
      return Result.error(
        Exception(error.toString()),
      );
    }
  }

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl() async {
    return await _authService.getAuthorizeUrl();
  }

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    final result = await _authService.processCallback(code);
    return result.when(
      ok: (response) => Result.ok(response),
      error: (error) => Result.error(error),
    );
  }

  /// Chama o endpoint de sucesso com o location_id
  Future<Result<void>> callSuccessEndpoint(String locationId) async {
    final result = await _authService.callSuccessEndpoint(locationId);
    return result.when(
      ok: (_) => Result.ok(null),
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

  /// Obtém o location_id atual
  Future<Result<String?>> getCurrentLocationId() async {
    return await _authService.getCurrentLocationId();
  }
}
