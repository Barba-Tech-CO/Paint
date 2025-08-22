import '../config/app_urls.dart';
import '../model/auth_model.dart';
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
      const String redirectUri =
          'https://paintpro.barbatech.company/api/auth/callback';
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
      _logger.info('[AuthService] Processing OAuth callback with code: ${code.substring(0, 8)}...');
      
      // Exchange the authorization code for tokens with the backend
      final response = await _httpService.get(
        '/auth/callback?code=$code',
      );

      _logger.info('[AuthService] Backend response: ${response.data}');
      
      final callbackResponse = AuthRefreshResponse.fromJson(response.data);

      if (callbackResponse.success && callbackResponse.locationId != null) {
        _logger.info('[AuthService] OAuth callback successful, location_id: ${callbackResponse.locationId}');
        
        // Call the success endpoint to complete the authentication
        await _callSuccessEndpoint(callbackResponse.locationId!);
      } else {
        _logger.warning('[AuthService] OAuth callback failed or missing location_id');
      }

      return Result.ok(callbackResponse);
    } on AuthServiceException catch (e) {
      _logger.info('[AuthService] Authentication service unavailable: ${e.message}');
      _logger.error('[AuthService] Technical details: ${e.technicalDetails}');
      return Result.error(Exception(e.message));
    } catch (e) {
      _logger.error('[AuthService] Error processing OAuth callback: $e');
      return Result.error(Exception('Erro no callback: $e'));
    }
  }

  /// Chama o endpoint de sucesso com o location_id
  Future<void> _callSuccessEndpoint(String locationId) async {
    try {
      // Make the actual HTTP request to the /success endpoint
      final response = await _httpService.get(
        '/auth/success?location_id=$locationId',
      );

      _logger.info(
        '[AuthService] Success endpoint response: ${response.data}',
      );
    } catch (e) {
      _logger.error('[AuthService] Error calling /success endpoint: $e');
      // Re-throw the error as this is important for the authentication flow
      rethrow;
    }
  }

  /// Chama o endpoint de sucesso com o location_id (método público)
  Future<Result<void>> callSuccessEndpoint(String locationId) async {
    try {
      await _callSuccessEndpoint(locationId);
      return Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception('Erro ao chamar endpoint de sucesso: $e'),
      );
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
}
