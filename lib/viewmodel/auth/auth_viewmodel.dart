import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_config.dart';
import '../../config/app_urls.dart';
import '../../model/auth_model/auth_model.dart';
import '../../model/auth_model/auth_state.dart';
import '../../model/user_model.dart';
import '../../service/auth_persistence_service.dart';
import '../../service/deep_link_service.dart';
import '../../service/http_service.dart';
import '../../use_case/auth/auth_operations_use_case.dart';
import '../../use_case/auth/handle_deep_link_use_case.dart';
import '../../use_case/auth/handle_webview_navigation_use_case.dart';
import '../../utils/command/command.dart';
import '../../utils/handlers/deep_link_handler.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';
import 'auth_view_state.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthOperationsUseCase _authOperationsUseCase;
  final HandleDeepLinkUseCase _handleDeepLinkUseCase;
  final HandleWebViewNavigationUseCase _handleWebViewNavigationUseCase;
  final DeepLinkService _deepLinkService;
  final AuthPersistenceService _authPersistenceService;
  final HttpService _httpService;
  final AppLogger _logger;
  late final DeepLinkHandler _deepLinkHandler;

  AuthViewState _state = AuthViewState.initial();
  AuthViewState get state => _state;

  // Flags para navegação e popup
  bool get shouldNavigateToDashboard =>
      _state.authStatus?.authenticated == true &&
      _state.authStatus?.needsLogin == false;
  bool get shouldShowPopup => _state.shouldShowPopup;
  String? get popupUrl => _state.popupUrl;

  // Comandos do Command Builder
  late final Command0<void> checkAuthStatusCommand = Command0(
    _checkAuthStatus,
  );
  late final Command1<void, String> processCallbackCommand = Command1(
    _processCallback,
  );
  late final Command0<void> refreshTokenCommand = Command0(_refreshToken);

  AuthViewModel(
    this._authOperationsUseCase,
    this._handleDeepLinkUseCase,
    this._handleWebViewNavigationUseCase,
    this._deepLinkService,
    this._authPersistenceService,
    this._httpService,
    this._logger,
  ) {
    _deepLinkHandler = DeepLinkHandler(
      _deepLinkService,
      _onDeepLinkReceived,
    );
    _deepLinkHandler.initialize();
    // Initialize auth state synchronously during construction
    _initializeAuthSync();
  }

  void _updateState(AuthViewState newState) {
    _state = newState;
    notifyListeners();
  }

  void _initializeAuthSync() {
    // Set initial state with authorize URL
    _updateState(
      _state.copyWith(
        authorizeUrl: AppConfig.isProduction
            ? AppUrls.goHighLevelAuthorizeUrl
            : AppUrls.goHighLevelAuthorizeUrlDev,
      ),
    );

    // Load persisted authentication state synchronously
    _loadPersistedAuthState();
  }

  void _loadPersistedAuthState() async {
    try {
      // Check if user is already authenticated from persisted state
      final isAuthenticated = await _authPersistenceService
          .isUserAuthenticated();

      if (isAuthenticated) {
        final persistedState = await _authPersistenceService.loadAuthState();

        _updateState(
          _state.copyWith(
            authStatus: AuthModel(
              authenticated: persistedState['authenticated'] as bool,
              needsLogin: persistedState['needsLogin'] as bool,
              expiresAt: persistedState['expiresAt'] as DateTime?,
              sanctumToken: persistedState['sanctumToken'] as String?,
              locationId: persistedState['locationId'] as String?,
            ),
            state: AuthState.authenticated,
            isLoading: false,
          ),
        );
      } else {
        // Check if token was expired and cleared
        final wasTokenExpired = await _authPersistenceService.isTokenExpired();
        if (wasTokenExpired) {
          _updateState(
            _state.copyWith(
              state: AuthState.unauthenticated,
              isLoading: false,
              errorMessage: 'Your session has expired. Please log in again.',
            ),
          );
          return;
        }

        // Check backend status if no persisted authentication
        // Only check backend status if we have a token, otherwise show login directly
        final hasToken = await _authPersistenceService.getSanctumToken();
        if (hasToken != null) {
          checkAuthStatusCommand.execute();
        } else {
          _updateState(
            _state.copyWith(
              state: AuthState.unauthenticated,
              isLoading: false,
              errorMessage: null,
              authorizeUrl: AppConfig.isProduction
                  ? AppUrls.goHighLevelAuthorizeUrl
                  : AppUrls.goHighLevelAuthorizeUrlDev,
            ),
          );
        }
      }
    } catch (e) {
      _logger.error('[AuthViewModel] Error loading persisted auth state: $e');
      // Fallback to unauthenticated state
      _updateState(
        _state.copyWith(
          state: AuthState.unauthenticated,
          isLoading: false,
          errorMessage: 'Failed to load authentication state',
        ),
      );
    }
  }

  void _onDeepLinkReceived(Uri uri) {
    if (uri.pathSegments.contains('success')) {
      _handleDeepLinkUseCase.handleSuccess().then((_) {
        // After handling success, check auth status to update navigation flags
        checkAuthStatusCommand.execute();
      });
    } else if (uri.pathSegments.contains('error')) {
      final error = uri.queryParameters['error'];
      _logger.error(
        '[AuthViewModel] Error in deep link: $error',
      );
      _handleDeepLinkUseCase.handleError(
        error ?? 'Unknown error in authentication',
      );
    }
  }

  // Métodos privados para os comandos
  Future<Result<void>> _checkAuthStatus() async {
    _updateState(
      _state.copyWith(
        isLoading: true,
        errorMessage: null,
      ),
    );
    final result = await _authOperationsUseCase.checkAuthStatus();
    return result.when(
      ok: (authModel) async {
        // Check if user is authenticated on backend but missing local token
        if (authModel.authenticated && !authModel.needsLogin) {
          final hasLocalToken = await _authPersistenceService.getSanctumToken();

          if (hasLocalToken == null) {
            // Force re-authentication to get fresh token
            final unauthenticatedModel = authModel.copyWith(needsLogin: true);
            _updateState(
              _state.copyWith(
                authStatus: unauthenticatedModel,
                state: AuthState.unauthenticated,
                isLoading: false,
                errorMessage: 'Please log in again to access your account',
              ),
            );
            return Result.ok(null);
          }
        }

        // Only update state if user is not already authenticated locally
        // This prevents backend from overriding successful OAuth authentication
        if (_state.authStatus?.authenticated != true) {
          final newState = authModel.authenticated && !authModel.needsLogin
              ? AuthState.authenticated
              : AuthState.unauthenticated;
          _updateState(
            _state.copyWith(
              authStatus: authModel,
              state: newState,
              isLoading: false,
              errorMessage: null,
            ),
          );

          // If backend confirms authentication, save it to persistence
          if (authModel.authenticated && !authModel.needsLogin) {
            final hasLocalToken = await _authPersistenceService
                .getSanctumToken();
            if (hasLocalToken != null) {
              await _authPersistenceService.saveAuthState(
                authenticated: true,
                needsLogin: false,
                expiresAt: authModel.expiresAt,
                sanctumToken: hasLocalToken,
              );
              _logger.info(
                '[AuthViewModel] Saved authentication state from backend confirmation',
              );
            }
          }
        } else {
          _updateState(_state.copyWith(isLoading: false));
        }

        return Result.ok(null);
      },
      error: (error) {
        _logger.error(
          '[AuthViewModel] Error checking auth status: $error',
        );

        // Check if it's a service unavailable error (HTTP 500) vs network/other errors
        final errorMessage = error.toString();
        final isServiceUnavailable = errorMessage.contains(
          'Authentication service is temporarily unavailable',
        );

        // Check if it's a "no auth token" error (expected on first launch)
        final isNoAuthTokenError =
            errorMessage.contains('No auth token') ||
            errorMessage.contains('401') ||
            errorMessage.contains('Unauthorized');

        if (isServiceUnavailable) {
          // Service unavailable - show error state and propagate error to CommandBuilder
          _updateState(
            _state.copyWith(
              state: AuthState.error,
              isLoading: false,
              errorMessage: errorMessage,
            ),
          );
          return Result.error(error);
        } else if (isNoAuthTokenError) {
          // No auth token error - treat as unauthenticated and show login (expected on first launch)
          _logger.info(
            '[AuthViewModel] No auth token found - treating as unauthenticated (expected on first launch)',
          );

          // Create a dummy unauthenticated model
          final unauthenticatedModel = AuthModel(
            authenticated: false,
            needsLogin: true,
            expiresAt: null,
            locationId: null,
          );

          _updateState(
            _state.copyWith(
              authStatus: unauthenticatedModel,
              state: AuthState.unauthenticated,
              isLoading: false,
              errorMessage: null, // Clear error to show webview
            ),
          );

          // Return success to CommandBuilder so it doesn't show error overlay
          return Result.ok(null);
        } else {
          // Other errors (network, etc.) - treat as unauthenticated and show login

          // Create a dummy unauthenticated model
          final unauthenticatedModel = AuthModel(
            authenticated: false,
            needsLogin: true,
            expiresAt: null,
            locationId: null,
          );

          _updateState(
            _state.copyWith(
              authStatus: unauthenticatedModel,
              state: AuthState.unauthenticated,
              isLoading: false,
              errorMessage: null, // Clear error to show webview
            ),
          );

          // Return success to CommandBuilder so it doesn't show error overlay
          return Result.ok(null);
        }
      },
    );
  }

  Future<Result<void>> _processCallback(String code) async {
    try {
      _updateState(
        _state.copyWith(
          isLoading: true,
          errorMessage: null,
        ),
      );

      final result = await _authOperationsUseCase.processCallback(code);

      result.when(
        ok: (response) async {
          if (response.success && response.locationId != null) {
            final authToken = response.authToken ?? response.sanctumToken;

            if (authToken == null) {
              // Redirect to error state since authentication is incomplete
              final errorMessage = kDebugMode
                  ? 'OAuth authentication incomplete. No token received from backend.'
                  : 'Authentication failed. Please try again.';

              _updateState(
                _state.copyWith(
                  state: AuthState.error,
                  isLoading: false,
                  errorMessage: errorMessage,
                ),
              );
              return; // Exit early, don't proceed with incomplete authentication
            }

            // Use the backend response data to create the auth status
            // If backend doesn't provide expiresAt or it's in the past, use a future date
            DateTime expiresAt;
            if (response.expiresAt != null &&
                response.expiresAt!.isAfter(DateTime.now())) {
              expiresAt = response.expiresAt!;
            } else {
              expiresAt = DateTime.now().add(const Duration(days: 30));
            }

            final newAuthStatus = AuthModel(
              authenticated: true,
              needsLogin: false,
              expiresAt: expiresAt,
              locationId: response.locationId,
            );

            _updateState(
              _state.copyWith(
                authStatus: newAuthStatus,
                state: AuthState.authenticated,
                isLoading: false,
                errorMessage: null,
              ),
            );

            // Save authentication state to persistence with backend data
            await _authPersistenceService.saveAuthState(
              authenticated: true,
              needsLogin: false,
              expiresAt: newAuthStatus.expiresAt,
              sanctumToken: authToken,
            );

            // Set the token in HTTP service immediately
            _httpService.setAuthToken(authToken);
          } else {
            _logger.error(
              '[AuthViewModel] OAuth callback failed or missing location_id',
            );
            _updateState(
              _state.copyWith(
                state: AuthState.error,
                isLoading: false,
                errorMessage: 'OAuth authentication failed',
              ),
            );
          }
        },
        error: (error) {
          _logger.error(
            '[AuthViewModel] Error processing callback: $error',
          );

          // Check if it's an authentication service unavailable error
          final errorMessage = error.toString();
          final isServiceUnavailable = errorMessage.contains(
            'Authentication service is temporarily unavailable',
          );

          _updateState(
            _state.copyWith(
              state: AuthState.error,
              isLoading: false,
              errorMessage: isServiceUnavailable
                  ? 'Authentication service is temporarily unavailable. Please try again in a few moments.'
                  : 'Unable to complete authentication at this time. Please try again.',
            ),
          );
        },
      );
      return result;
    } catch (e, stack) {
      _logger.error(
        '[AuthViewModel] Unexpected error in processCallback',
        e,
        stack,
      );
      _updateState(
        _state.copyWith(
          state: AuthState.error,
          isLoading: false,
          errorMessage: 'Something went wrong. Please try again.',
        ),
      );
      return Result.error(
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<Result<void>> _refreshToken() async {
    _updateState(
      _state.copyWith(
        isLoading: true,
        errorMessage: null,
      ),
    );

    final result = await _authOperationsUseCase.refreshToken();

    result.when(
      ok: (response) {
        checkAuthStatusCommand.execute();
      },
      error: (error) {
        _updateState(
          _state.copyWith(
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      },
    );

    return result;
  }

  Future<String?> getAuthorizeUrl() async {
    final result = await _authOperationsUseCase.getAuthorizeUrl();
    return result.when(
      ok: (url) => url,
      error: (error) {
        _updateState(
          _state.copyWith(errorMessage: 'Erro ao obter URL de autorização'),
        );
        return null;
      },
    );
  }

  Future<void> processCallback(String code) async {
    processCallbackCommand.execute(code);
  }

  Future<void> refreshToken() async {
    refreshTokenCommand.execute();
  }

  Future<bool> isTokenExpiringSoon() async {
    final result = await _authOperationsUseCase.isTokenExpiringSoon();
    return result.when(
      ok: (isExpiring) => isExpiring,
      error: (error) => true,
    );
  }

  Future<void> setLoading(bool loading) async {
    _updateState(_state.copyWith(isLoading: loading));
  }

  Future<void> setError(String error) async {
    _updateState(_state.copyWith(errorMessage: error));
  }

  Future<void> clearError() async {
    _updateState(_state.copyWith(errorMessage: null));
  }

  Future<void> handleError(String error) async {
    _updateState(_state.copyWith(errorMessage: error));
  }

  Future<NavigationDecision> handleWebViewNavigation(String url) async {
    return await _handleWebViewNavigationUseCase.handleNavigation(
      url,
      (error) => handleError(error),
      (code) => processCallback(code),
    );
  }

  void showMarketplacePopup(String url) {
    _updateState(_state.copyWith(shouldShowPopup: true, popupUrl: url));
  }

  void closeMarketplacePopup() {
    _updateState(_state.copyWith(shouldShowPopup: false, popupUrl: null));
  }

  void updateAuthorizeUrl(String newUrl) {
    _updateState(_state.copyWith(authorizeUrl: newUrl));
  }

  /// Triggers a deep link success callback for testing or manual triggering
  void triggerDeepLinkSuccess() {
    _deepLinkService.triggerSuccessCallback();
  }

  /// Retries the authentication flow by completely restarting the auth process
  Future<void> retryAuthentication() async {
    // Clear any existing authentication state
    await _authPersistenceService.forceLogout();

    // Reset state to initial
    _updateState(
      _state.copyWith(
        state: AuthState.initial,
        errorMessage: null,
        isLoading: false,
        authStatus: null,
        authorizeUrl: null,
      ),
    );

    // Generate new authorization URL using the same logic as initialization
    final newUrl = await getAuthorizeUrl();
    if (newUrl != null) {
      _updateState(
        _state.copyWith(
          authorizeUrl: newUrl,
          state: AuthState.unauthenticated,
          isLoading: false,
        ),
      );
    } else {
      _updateState(
        _state.copyWith(
          state: AuthState.error,
          errorMessage: 'Failed to generate authorization URL',
        ),
      );
    }
  }

  Future<Result<AuthState>> reset() async {
    _updateState(AuthViewState.initial());
    return Result.ok(AuthState.initial);
  }

  /// Obtém dados completos do usuário autenticado
  Future<Result<UserModel>> getUserData() async {
    final result = await _authOperationsUseCase.getUser();
    return result.when(
      ok: (user) {
        final userModel = user;
        return Result.ok(userModel);
      },
      error: (error) {
        _logger.error('[AuthViewModel] Error getting user data: $error');
        return Result.error(error);
      },
    );
  }

  /// Force logout by clearing all authentication data
  Future<void> logout() async {
    // Use AuthOperationsUseCase to handle logout (clears HTTP tokens)
    final result = await _authOperationsUseCase.logout();

    // Clear authentication state from persistence
    await _authPersistenceService.forceLogout();

    // Update state to unauthenticated
    _updateState(
      _state.copyWith(
        authStatus: AuthModel(
          authenticated: false,
          needsLogin: true,
          expiresAt: null,
          locationId: null,
          sanctumToken: null,
        ),
        state: AuthState.unauthenticated,
        isLoading: false,
        errorMessage: null,
      ),
    );

    result.when(
      ok: (_) {},
      error: (error) => _logger.error(
        '[AuthViewModel] Error during logout: $error',
      ),
    );
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }
}
