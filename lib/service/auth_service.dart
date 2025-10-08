import '../model/auth_model/auth_model.dart';
import '../model/auth_model/auth_status_response.dart';
import '../model/auth_model/auth_refresh_response.dart';
import '../model/user_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'auth_persistence_service.dart';
import 'auth_service_exception.dart';
import 'http_service.dart';

class AuthService {
  final HttpService _httpService;
  final AuthPersistenceService _authPersistenceService;
  final AppLogger _logger;

  AuthService(
    this._httpService,
    this._authPersistenceService,
    this._logger,
  );

  /// Build AuthModel snapshot from current state
  AuthModel _buildAuthModel({
    required bool authenticated,
    required bool needsLogin,
    String? locationId,
    String? token,
    DateTime? expiresAt,
  }) {
    final now = DateTime.now();
    final remaining = expiresAt?.difference(now);

    return AuthModel(
      authenticated: authenticated,
      needsLogin: needsLogin,
      locationId: locationId,
      sanctumToken: token,
      expiresAt: expiresAt,
      expiresInMinutes: remaining?.inMinutes,
      expiresIn: remaining?.inSeconds,
      isExpiringSoon: remaining != null ? remaining.inMinutes < 60 : null,
      tokenValid: authenticated && !needsLogin,
    );
  }

  /// Helper to produce a Result<AuthStatusResponse>
  Result<AuthStatusResponse> _authStatusResult(AuthModel model) {
    return Result.ok(
      AuthStatusResponse(
        success: true,
        data: model,
      ),
    );
  }

  /// Resolve stored authentication state before hitting the network
  Future<Map<String, dynamic>> _loadStoredAuthState() async {
    try {
      return await _authPersistenceService.loadAuthState();
    } catch (e) {
      _logger.error('[AuthService] Failed to load stored auth state: $e');
      return {
        'authenticated': false,
        'needsLogin': true,
        'locationId': null,
        'expiresAt': null,
        'sanctumToken': null,
      };
    }
  }

  /// Verifica o status de autenticação
  Future<Result<AuthStatusResponse>> getStatus() async {
    try {
      final storedState = await _loadStoredAuthState();
      final storedToken = storedState['sanctumToken'] as String?;
      final locationFromStore = storedState['locationId'] as String?;
      final expiresAt = storedState['expiresAt'] as DateTime?;

      final token = storedToken?.isNotEmpty == true
          ? storedToken
          : _httpService.ghlToken;

      if (token == null || token.isEmpty) {
        _httpService.clearAuthToken();
        return _authStatusResult(
          _buildAuthModel(
            authenticated: false,
            needsLogin: true,
            locationId: null,
            token: null,
            expiresAt: null,
          ),
        );
      }

      // Ensure HttpService carries the latest token
      _httpService.setAuthToken(token);

      final response = await _httpService.get('/user');

      if (response.statusCode == 401) {
        await logout();
        return _authStatusResult(
          _buildAuthModel(
            authenticated: false,
            needsLogin: true,
            locationId: null,
            token: null,
            expiresAt: null,
          ),
        );
      }

      if (response.statusCode != 200) {
        _logger.error(
          '[AuthService] Unexpected status from /user: ${response.statusCode}',
        );
        return Result.error(
          Exception('Failed to verify authentication status'),
        );
      }

      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      final resolvedLocation = user.ghlLocationId?.isNotEmpty == true
          ? user.ghlLocationId
          : locationFromStore;

      return _authStatusResult(
        _buildAuthModel(
          authenticated: true,
          needsLogin: false,
          locationId: resolvedLocation,
          token: token,
          expiresAt: expiresAt,
        ),
      );
    } catch (e, stack) {
      _logger.error(
        '[AuthService] Error checking authentication status: $e',
        e,
        stack,
      );
      return Result.error(
        Exception('Error checking authentication status: $e'),
      );
    }
  }

  /// Obtém a URL de autorização (mantido para compatibilidade futura)
  Future<Result<String>> getAuthorizeUrl() async {
    return Result.error(
      Exception(
        'Marketplace authorization flow is not supported for credential login.',
      ),
    );
  }

  /// Fluxo de callback não é suportado no login por credenciais
  Future<Result<AuthRefreshResponse>> processCallback(String code) async {
    return Result.error(
      Exception(
        'OAuth callback not supported for credential-based authentication',
      ),
    );
  }

  /// Refresh de token não implementado no fluxo atual
  Future<Result<AuthRefreshResponse>> refreshToken() async {
    return Result.error(
      Exception(
        'Token refresh not available for credential-based authentication',
      ),
    );
  }

  /// Verifica se está autenticado
  Future<Result<bool>> isAuthenticated() async {
    final statusResult = await getStatus();
    return statusResult.when(
      ok: (status) =>
          Result.ok(status.data.authenticated && !status.data.needsLogin),
      error: (error) => Result.error(error),
    );
  }

  /// Verifica se o token está próximo de expirar
  Future<Result<bool>> isTokenExpiringSoon() async {
    final storedState = await _loadStoredAuthState();
    final expiresAt = storedState['expiresAt'] as DateTime?;

    if (expiresAt == null) {
      // Without expiration data, assume token is valid
      return Result.ok(false);
    }

    final difference = expiresAt.difference(DateTime.now());
    return Result.ok(difference.inMinutes < 60);
  }

  /// Obtém o location_id atual
  Future<Result<String?>> getCurrentLocationId() async {
    try {
      final storedState = await _loadStoredAuthState();
      final storedLocation = storedState['locationId'] as String?;
      if (storedLocation != null && storedLocation.isNotEmpty) {
        return Result.ok(storedLocation);
      }

      final statusResult = await getStatus();
      return statusResult.when(
        ok: (status) => Result.ok(status.data.locationId),
        error: (error) => Result.error(error),
      );
    } catch (e) {
      return Result.error(Exception('Error getting location_id: $e'));
    }
  }

  /// Obtém dados completos do usuário autenticado
  Future<Result<UserModel>> getUser() async {
    try {
      final response = await _httpService.get('/user');

      if (response.statusCode == 401) {
        return Result.error(
          AuthServiceException(
            message: 'Authentication required',
            errorType: AuthServiceErrorType.invalidCredentials,
            technicalDetails: 'GET /user returned 401',
          ),
        );
      }

      if (response.statusCode != 200) {
        return Result.error(
          Exception('Failed to load user data: ${response.statusCode}'),
        );
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return Result.error(
          Exception('Unexpected user payload format'),
        );
      }

      final user = UserModel.fromJson(data);
      return Result.ok(user);
    } on AuthServiceException catch (e) {
      _logger.error('[AuthService] Technical details: ${e.technicalDetails}');
      return Result.error(Exception(e.message));
    } catch (e, stack) {
      _logger.error('[AuthService] Error getting user data: $e', e, stack);
      return Result.error(
        Exception('Error getting user data: $e'),
      );
    }
  }

  /// Executa logout limpando tokens e estado de autenticação
  Future<void> logout() async {
    await _authPersistenceService.clearAuthState();
    _httpService.clearAuthToken();
  }
}
