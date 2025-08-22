import '../config/app_urls.dart';
import '../model/auth_model.dart';
import '../model/user_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'auth_service_exception.dart';
import 'services.dart';

class AuthService {
  final HttpService _httpService;
  final AppLogger _logger;

  AuthService(this._httpService, this._logger);

  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus() async {
    try {
      // Make the actual HTTP request to check authentication status
      final response = await _httpService.get('/auth/status');
      final authStatus = AuthStatusResponse.fromJson(response.data);
      return Result.ok(authStatus);
    } catch (e) {
      _logger.error('Error checking authentication status: $e');
      return Result.error(
        Exception('Error checking authentication status: $e'),
      );
    }
  }

  /// Obtém a URL de autorização
  Future<Result<String>> getAuthorizeUrl() async {
    try {
      // Construct the OAuth2 authorization URL directly
      // No need to make an HTTP request for OAuth2 authorization URLs
      const String baseUrl =
          'https://marketplace.gohighlevel.com/oauth/chooselocation';
      const String clientId = '6845ab8de6772c0d5c8548d7-mbnty1f6';
      
      // Use the correct redirect URI based on the environment
      final String redirectUri = '${_httpService.dio.options.baseUrl.replaceAll('/api', '')}/api/auth/callback';
      
      _logger.info('[AuthService] Using redirect URI: $redirectUri');
      
      const String scope =
          'contacts.write+associations.write+associations.readonly+oauth.readonly+oauth.write+invoices%2Festimate.write+invoices%2Festimate.readonly+invoices.readonly+associations%2Frelation.write+associations%2Frelation.readonly+contacts.readonly+invoices.write';

      final Uri authUri = Uri.parse(baseUrl).replace(
        queryParameters: {
          'response_type': 'code',
          'redirect_uri': redirectUri,
          'client_id': clientId,
          'scope': scope,
        },
      );

      _logger.info('[AuthService] Authorization URL: $authUri');

      return Result.ok(authUri.toString());
    } catch (e) {
      _logger.error('Error generating authorization URL: $e');
      return Result.error(
        Exception('Error generating authorization URL: $e'),
      );
    }
  }

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    try {
      _logger.info(
        '[AuthService] Processing OAuth callback with code: ${code.substring(0, 8)}...',
      );

      final callbackUrl = '/auth/callback?code=$code';
      _logger.info('[AuthService] Making request to: $callbackUrl');

      // Exchange the authorization code for tokens with the backend
      final response = await _httpService.get(callbackUrl);

      _logger.info('[AuthService] Callback response JSON: ${response.data}');

      final callbackResponse = AuthRefreshResponse.fromJson(response.data);

      if (callbackResponse.success && callbackResponse.locationId != null) {
        _logger.info(
          '[AuthService] OAuth callback successful, location_id: ${callbackResponse.locationId}',
        );

        // Check if we received a valid token
        if (callbackResponse.authToken == null &&
            callbackResponse.sanctumToken == null) {
          _logger.warning(
            '[AuthService] No authentication token received from backend. '
            'This indicates the OAuth flow is incomplete on the backend side. '
            'The user will need to complete authentication through the backend.',
          );
        }
      } else {
        _logger.warning(
          '[AuthService] OAuth callback failed or missing location_id',
        );
      }

      return Result.ok(callbackResponse);
    } on AuthServiceException catch (e) {
      _logger.info(
        '[AuthService] Authentication service unavailable: ${e.message}',
      );
      _logger.error('[AuthService] Technical details: ${e.technicalDetails}');
      return Result.error(Exception(e.message));
    } catch (e) {
      _logger.error('[AuthService] Error processing OAuth callback: $e');
      return Result.error(Exception('Erro no callback: $e'));
    }
  }

  /// Renova o token de acesso
  Future<Result<AuthRefreshResponse>> refreshToken() async {
    try {
      // Make the actual HTTP request to refresh the token
      final response = await _httpService.post(
        AppUrls.authRefreshUrl,
        data: {},
      );
      final refreshResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(refreshResponse);
    } catch (e) {
      _logger.error('Error refreshing token: $e');
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

  /// Obtém dados completos do usuário autenticado
  Future<Result<UserModel>> getUser() async {
    try {
      final response = await _httpService.get('/user');
      final user = UserModel.fromJson(response.data);
      _logger.info('[AuthService] User data retrieved successfully');
      return Result.ok(user);
    } on AuthServiceException catch (e) {
      _logger.info(
        '[AuthService] Authentication service unavailable: ${e.message}',
      );
      _logger.error('[AuthService] Technical details: ${e.technicalDetails}');
      return Result.error(Exception(e.message));
    } catch (e) {
      _logger.error('[AuthService] Error getting user data: $e');
      return Result.error(
        Exception('Error getting user data: $e'),
      );
    }
  }
}
