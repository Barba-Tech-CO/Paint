import '../model/auth_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';
import 'services.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus() async {
    try {
      // Make the actual HTTP request to check authentication status
      final response = await _httpService.get('/auth/status');
      final authStatus = AuthStatusResponse.fromJson(response.data);
      return Result.ok(authStatus);
    } catch (e) {
      return Result.error(
        Exception('Erro ao verificar status: $e'),
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
          'https://paintpro.barbatech.company/api/oauth/callback';
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
      return Result.error(
        Exception('Erro ao obter URL de autorização: $e'),
      );
    }
  }

  /// Processa o callback de autorização
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    try {
      // In a real OAuth flow, we need to exchange the authorization code for tokens
      // This typically involves making a request to the token endpoint
      final response = await _httpService.get(
        '/auth/callback?code=$code',
      );

      final callbackResponse = AuthRefreshResponse.fromJson(response.data);

      // After successful token exchange, call the /success endpoint with location_id
      // The location_id should come from the OAuth response or user selection
      if (callbackResponse.success) {
        // Extract location_id from the response or use a default
        // In GoHighLevel's OAuth flow, the location_id is typically selected by the user
        // during the authorization process and returned in the callback
        final locationId =
            response.data['location_id'] ?? 'default_location_id';
        await _callSuccessEndpoint(locationId);
      }

      return Result.ok(callbackResponse);
    } catch (e) {
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

      LoggerService.info(
        '[AuthService] Success endpoint response: ${response.data}',
      );
    } catch (e) {
      LoggerService.error('[AuthService] Error calling /success endpoint: $e');
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
      return Result.error(Exception('Erro ao chamar endpoint de sucesso: $e'));
    }
  }

  /// Renova o token de acesso
  Future<Result<AuthRefreshResponse>> refreshToken() async {
    try {
      // Make the actual HTTP request to refresh the token
      final response = await _httpService.post(
        '/auth/refresh',
        data: {},
      );
      final refreshResponse = AuthRefreshResponse.fromJson(response.data);
      return Result.ok(refreshResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao renovar token: $e'));
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
          Exception('Erro ao verificar autenticação'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Erro ao verificar autenticação: $e'),
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

        final now = DateTime.now();
        final expiresAt = status.data.expiresAt!;
        final difference = expiresAt.difference(now);

        return Result.ok(difference.inMinutes < 60);
      } else {
        return Result.error(
          Exception('Erro ao verificar expiração do token'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Erro ao verificar expiração do token: $e'),
      );
    }
  }
}
