import '../model/auth_model.dart';
import '../utils/result/result.dart';
import '../config/app_urls.dart';
import 'http_service.dart';
import 'logger_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus() async {
    try {
      final response = await _httpService.get(AppUrls.authStatusUrl);
      final authStatus = AuthStatusResponse.fromJson(response.data);
      return Result.ok(authStatus);
    } catch (e) {
      LoggerService.error('Error checking authentication status: $e');
      return Result.error(
        Exception('Error checking authentication status: $e'),
      );
    }
  }

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl() async {
    try {
      LoggerService.info(
        'Authorization URL generated: ${AppUrls.goHighLevelAuthorizeUrl}',
      );
      return Result.ok(AppUrls.goHighLevelAuthorizeUrl);
    } catch (e) {
      LoggerService.error('Error generating authorization URL: $e');
      return Result.error(
        Exception('Error generating authorization URL: $e'),
      );
    }
  }

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    try {
      final response = await _httpService.post(
        AppUrls.authCallbackUrl,
        data: {'code': code},
      );
      final callbackResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(callbackResponse);
    } catch (e) {
      LoggerService.error('Error processing callback: $e');
      return Result.error(
        Exception('Error processing callback: $e'),
      );
    }
  }

  /// Renova o token de acesso
  Future<Result<AuthRefreshResponse>> refreshToken() async {
    try {
      final response = await _httpService.post(
        AppUrls.authRefreshUrl,
        data: {},
      );
      final refreshResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(refreshResponse);
    } catch (e) {
      LoggerService.error('Error refreshing token: $e');
      return Result.error(
        Exception('Error refreshing token: $e'),
      );
    }
  }

  /// Verifica se está autenticado
  Future<Result<bool>> isAuthenticated() async {
    try {
      final statusResult = await getStatus();
      if (statusResult is Ok) {
        final status = statusResult.asOk.value;
        return Result.ok(status.data.authenticated && !status.data.needsLogin);
      } else {
        return Result.error(
          Exception('Error checking authentication'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error checking authentication: $e'),
      );
    }
  }

  /// Verifica se o token está próximo de expirar
  Future<Result<bool>> isTokenExpiringSoon() async {
    try {
      final statusResult = await getStatus();
      if (statusResult is Ok) {
        final status = statusResult.asOk.value;
        if (!status.data.authenticated || status.data.expiresAt == null) {
          return Result.ok(true);
        }

        // Use the isExpiringSoon field from the API response if available
        if (status.data.isExpiringSoon != null) {
          return Result.ok(status.data.isExpiringSoon!);
        }

        // Fallback to manual calculation
        final now = DateTime.now();
        final expiresAt = status.data.expiresAt!;
        final difference = expiresAt.difference(now);

        return Result.ok(difference.inMinutes < 60);
      } else {
        return Result.error(
          Exception('Error checking token expiration'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error checking token expiration: $e'),
      );
    }
  }

  /// Obtém o location_id atual
  Future<Result<String?>> getCurrentLocationId() async {
    try {
      final statusResult = await getStatus();
      if (statusResult is Ok) {
        final status = statusResult.asOk.value;
        return Result.ok(status.data.locationId);
      } else {
        return Result.error(
          Exception('Error getting location_id'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error getting location_id: $e'),
      );
    }
  }
}
