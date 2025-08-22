import '../../model/auth_model.dart';
import '../../model/user_model.dart';
import '../../utils/result/result.dart';

abstract class IAuthRepository {
  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus();

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl();

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code);

  /// Renova o token de acesso
  Future<Result<AuthRefreshResponse>> refreshToken();

  /// Verifica se está autenticado
  Future<Result<bool>> isAuthenticated();

  /// Verifica se o token está próximo de expirar
  Future<Result<bool>> isTokenExpiringSoon();

  /// Obtém o location_id atual
  Future<Result<String?>> getCurrentLocationId();

  /// Obtém dados completos do usuário autenticado
  Future<Result<UserModel>> getUser();
}
