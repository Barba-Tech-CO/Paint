import '../../utils/result/result.dart';
import '../../features/auth/domain/entities/auth_status_response_entity.dart';
import '../../features/auth/domain/entities/auth_refresh_response_entity.dart';

abstract class IAuthRepository {
  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponseEntity>> getStatus();

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl();

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponseEntity>> processCallback(String code);

  /// Renova o token de acesso
  Future<Result<AuthRefreshResponseEntity>> refreshToken();

  /// Verifica se está autenticado
  Future<Result<bool>> isAuthenticated();

  /// Verifica se o token está próximo de expirar
  Future<Result<bool>> isTokenExpiringSoon();
}
