import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/app_urls.dart';
import '../../model/models.dart';
import '../../model/user_model.dart';
import '../../service/auth_persistence_service.dart';
import '../../service/deep_link_service.dart';
import '../../use_case/auth/auth_use_cases.dart';
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
  late final Command0<AuthModel> checkAuthStatusCommand = Command0(
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
    this._logger,
  ) {
    _deepLinkHandler = DeepLinkHandler(
      _deepLinkService,
      _onDeepLinkReceived,
    );
    _deepLinkHandler.initialize();
    // Use microtask to handle async initialization
    Future.microtask(() => _initializeAuth());
  }

  void _updateState(AuthViewState newState) {
    _state = newState;
    notifyListeners();
  }

  void _initializeAuth() async {
    _updateState(
      _state.copyWith(
        authorizeUrl: AppUrls.goHighLevelAuthorizeUrl,
      ),
    );

    // First check if user is already authenticated from persisted state
    final isAuthenticated = await _authPersistenceService.isUserAuthenticated();

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
      // Check backend status if no persisted authentication
      checkAuthStatusCommand.execute();
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
  Future<Result<AuthModel>> _checkAuthStatus() async {
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
            _logger.warning(
              '[AuthViewModel] User authenticated on backend but no local token - requiring re-authentication',
            );
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
            return Result.ok(unauthenticatedModel);
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
        } else {
          _updateState(_state.copyWith(isLoading: false));
        }

        return Result.ok(authModel);
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
        } else {
          // Other errors (network, etc.) - treat as unauthenticated and show login
          _logger.warning(
            '[AuthViewModel] Network or connection error, treating as unauthenticated: $errorMessage',
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
          return Result.ok(unauthenticatedModel);
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
              _logger.warning(
                '[AuthViewModel] No authentication token received from backend. '
                'This indicates the OAuth flow is incomplete on the backend side. '
                'The user will need to complete authentication through the backend.',
              );

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
            final newAuthStatus = AuthModel(
              authenticated: true,
              needsLogin: false,
              expiresAt:
                  response.expiresAt ??
                  DateTime.now().add(
                    const Duration(days: 30),
                  ),
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
              locationId: newAuthStatus.locationId,
              sanctumToken: authToken,
            );
            
            // Ensure HTTP client is ready with auth token before navigation
            _logger.info('[AuthViewModel] Authentication complete - token saved and HTTP client configured');
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

  /// Retries the authentication flow by clearing error state and reloading
  Future<void> retryAuthentication() async {
    _updateState(
      _state.copyWith(
        state: AuthState.initial,
        errorMessage: null,
        isLoading: false,
      ),
    );

    // Reload the WebView by updating the authorize URL
    final newUrl = await getAuthorizeUrl();
    if (newUrl != null) {
      _updateState(
        _state.copyWith(authorizeUrl: newUrl),
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
        _logger.info('[AuthViewModel] User data retrieved: ${user.name}');

        // Log special states for debugging
        if (user.ghlDataIncomplete == true) {
          _logger.warning('[AuthViewModel] User has incomplete GHL data');
        }
        if (user.ghlError == true) {
          _logger.warning('[AuthViewModel] User has GHL error');
        }

        return Result.ok(user);
      },
      error: (error) {
        _logger.error('[AuthViewModel] Error getting user data: $error');
        return Result.error(error);
      },
    );
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }
}
