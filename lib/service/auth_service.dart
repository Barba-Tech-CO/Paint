import '../config/app_config.dart';
import '../config/app_urls.dart';
import '../model/auth_model/auth_refresh_response.dart';
import '../model/auth_model/auth_status_response.dart';
import '../model/user_model.dart';
import '../utils/auth/token_sanitizer.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'auth_service_exception.dart';
import 'http_service.dart';
import 'location_service.dart';

class AuthService {
  final HttpService _httpService;
  final LocationService _locationService;
  final AppLogger _logger;

  AuthService(this._httpService, this._locationService, this._logger);

  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus() async {
    try {
      // Make the actual HTTP request to check authentication status
      final response = await _httpService.get('/auth/status');
      final authStatus = AuthStatusResponse.fromJson(response.data);

      // Update location service if we have a location ID from the status
      if (authStatus.data.locationId != null &&
          authStatus.data.locationId!.isNotEmpty) {
        _locationService.setLocationId(authStatus.data.locationId!);
      }

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
      // Use the pre-configured URLs from AppUrls
      final String authUrl = AppConfig.isProduction
          ? AppUrls.goHighLevelAuthorizeUrl
          : AppUrls.goHighLevelAuthorizeUrlDev;

      return Result.ok(authUrl);
    } catch (e) {
      _logger.error('Error getting authorization URL: $e');
      return Result.error(
        Exception('Error getting authorization URL: $e'),
      );
    }
  }

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    try {
      final callbackUrl = '/auth/callback?code=$code';

      // Exchange the authorization code for tokens with the backend
      final response = await _httpService.get(callbackUrl);

      final callbackResponse = AuthRefreshResponse.fromJson(response.data);

      // After successful token exchange, call the /success endpoint with location_id
      // The location_id should come from the OAuth response or user selection
      if (callbackResponse.success) {
        // Extract auth_token and location_id from the response
        final authToken =
            response.data['auth_token'] ??
            response.data['sanctum_token'] ??
            callbackResponse.authToken;
        final locationId =
            response.data['location_id'] ??
            response.data['locationId'] ??
            callbackResponse.locationId;

        if (locationId != null && locationId.isNotEmpty) {
          // Store the location ID in the LocationService
          _locationService.setLocationId(locationId);

          // CRITICAL FIX: Sanitize and set the auth token in the HTTP service for all future requests
          final sanitizedToken = TokenSanitizer.sanitizeToken(authToken);
          if (sanitizedToken != null) {
            _httpService.setAuthToken(sanitizedToken);
          }

          // Call the success endpoint
          await _callSuccessEndpoint(locationId);
        } else {
          return Result.error(
            Exception('Location ID not found in OAuth response'),
          );
        }
      }

      return Result.ok(callbackResponse);
    } on AuthServiceException catch (e) {
      _logger.error('[AuthService] Technical details: ${e.technicalDetails}');
      return Result.error(Exception(e.message));
    } catch (e) {
      _logger.error('[AuthService] Error processing OAuth callback: $e');
      return Result.error(Exception('Erro no callback: $e'));
    }
  }

  /// Chama o endpoint de sucesso com o location_id
  Future<Result> _callSuccessEndpoint(String locationId) async {
    try {
      // Use the status endpoint instead of the non-existent success endpoint
      final response = await _httpService.get(
        '/auth/status?location_id=$locationId',
      );

      return Result.ok(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Chama o endpoint de sucesso com o location_id (método público)
  Future<Result<void>> callSuccessEndpoint(String locationId) async {
    try {
      await _callSuccessEndpoint(locationId);
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception('Erro ao chamar endpoint de sucesso: $e'));
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
      // First check if we have it in memory
      if (_locationService.hasLocationId) {
        return Result.ok(_locationService.currentLocationId);
      }

      // If not in memory, try to get it from the API status
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
      return Result.ok(user);
    } on AuthServiceException catch (e) {
      _logger.error('[AuthService] Technical details: ${e.technicalDetails}');
      return Result.error(Exception(e.message));
    } catch (e) {
      _logger.error('[AuthService] Error getting user data: $e');
      return Result.error(
        Exception('Error getting user data: $e'),
      );
    }
  }

  /// Executa logout limpando tokens e estado de autenticação
  Future<void> logout() async {
    // Clear HTTP service token
    _httpService.clearAuthToken();
  }
}
