import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

import '../../config/app_urls.dart';
import '../../model/auth_model.dart';
import '../../model/auth_state.dart';
import '../../service/auth_persistence_service.dart';
import '../../service/deep_link_service.dart';
import '../../use_case/auth/auth_use_cases.dart';
import '../../utils/command/command.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';
import 'auth_view_state.dart';

class _DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  final AppLogger _logger;
  final void Function(Uri) onDeepLink;
  StreamSubscription? _subscription;

  _DeepLinkHandler(
    this._deepLinkService,
    this._logger,
    this.onDeepLink,
  );

  void initialize() {
    _subscription = _deepLinkService.deepLinkStream.listen((uri) {
      _logger.info('[DeepLinkHandler] Deep Link recebido: $uri');
      onDeepLink(uri);
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class AuthViewModel extends ChangeNotifier {
  final AuthOperationsUseCase _authOperationsUseCase;
  final HandleDeepLinkUseCase _handleDeepLinkUseCase;
  final HandleWebViewNavigationUseCase _handleWebViewNavigationUseCase;
  final DeepLinkService _deepLinkService;
  final AuthPersistenceService _authPersistenceService;
  final AppLogger _logger;
  late final _DeepLinkHandler _deepLinkHandler;

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
    _deepLinkHandler = _DeepLinkHandler(
      _deepLinkService,
      _logger,
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
    _logger.info('[AuthViewModel] Initializing authentication...');
    _updateState(
      _state.copyWith(authorizeUrl: AppUrls.ghlAuthorizeUrl),
    );

    // First check if user is already authenticated from persisted state
    _logger.info('[AuthViewModel] Checking persisted authentication state...');
    final isAuthenticated = await _authPersistenceService.isUserAuthenticated();
    _logger.info(
      '[AuthViewModel] Persisted auth check result: $isAuthenticated',
    );

    if (isAuthenticated) {
      _logger.info('[AuthViewModel] User authenticated from persisted state');
      final persistedState = await _authPersistenceService.loadAuthState();
      _logger.info('[AuthViewModel] Loaded persisted state: $persistedState');

      _updateState(
        _state.copyWith(
          authStatus: AuthModel(
            authenticated: persistedState['authenticated'] as bool,
            needsLogin: persistedState['needsLogin'] as bool,
            expiresAt: persistedState['expiresAt'] as DateTime?,
            locationId: persistedState['locationId'] as String?,
          ),
          state: AuthState.authenticated,
          isLoading: false,
        ),
      );
      _logger.info(
        '[AuthViewModel] State updated to authenticated from persistence',
      );
    } else {
      _logger.info('[AuthViewModel] No persisted auth, checking backend...');
      // Check backend status if no persisted authentication
      checkAuthStatusCommand.execute();
    }
  }

  void _onDeepLinkReceived(Uri uri) {
    if (uri.pathSegments.contains('success')) {
      _handleDeepLinkUseCase.handleSuccess();
    } else if (uri.pathSegments.contains('error')) {
      final error = uri.queryParameters['error'];
      _handleDeepLinkUseCase.handleError(
        error ?? 'Erro desconhecido na autenticação',
      );
    }
  }

  // Métodos privados para os comandos
  Future<Result<AuthModel>> _checkAuthStatus() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    final result = await _authOperationsUseCase.checkAuthStatus();
    result.when(
      ok: (authModel) {
        _logger.info(
          '[AuthViewModel] Auth status from backend: authenticated=${authModel.authenticated}, needsLogin=${authModel.needsLogin}',
        );

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
          _logger.info(
            '[AuthViewModel] User already authenticated locally, keeping current state',
          );
          _updateState(_state.copyWith(isLoading: false));
        }
      },
      error: (error) {
        _updateState(
          _state.copyWith(
            state: AuthState.error,
            isLoading: false,
            errorMessage: error.toString(),
          ),
        );
      },
    );
    return result;
  }

  Future<Result<void>> _processCallback(String code) async {
    try {
      _updateState(_state.copyWith(isLoading: true, errorMessage: null));
      final result = await _authOperationsUseCase.processCallback(code);
      result.when(
        ok: (response) async {
          _logger.info('[AuthViewModel] Callback processado com sucesso');

          // After successful OAuth callback, force local authentication state
          // This prevents infinite login loops while backend processes the authentication
          final newAuthStatus = AuthModel(
            authenticated: true,
            needsLogin: false,
            // Set expiration to 30 days from now instead of using backend's incorrect date
            expiresAt: DateTime.now().add(const Duration(days: 30)),
            locationId: _state.authStatus?.locationId,
          );

          _updateState(
            _state.copyWith(
              authStatus: newAuthStatus,
              state: AuthState.authenticated,
              isLoading: false,
              errorMessage: null,
            ),
          );

          // Save authentication state to persistence
          await _authPersistenceService.saveAuthState(
            authenticated: true,
            needsLogin: false,
            expiresAt: newAuthStatus.expiresAt,
            locationId: newAuthStatus.locationId,
          );

          // Also check backend status after a delay to sync with server
          // But only if user is not already authenticated locally
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (_state.authStatus?.authenticated == true) {
              _logger.info(
                '[AuthViewModel] User already authenticated, skipping backend sync',
              );
            } else {
              _logger.info(
                '[AuthViewModel] Syncing with backend auth status...',
              );
              checkAuthStatusCommand.execute();
            }
          });
        },
        error: (error) {
          _updateState(
            _state.copyWith(isLoading: false, errorMessage: error.toString()),
          );
        },
      );
      return result;
    } catch (e, stack) {
      _logger.error(
        '[AuthViewModel] Erro inesperado no processCallback',
        e,
        stack,
      );
      _updateState(
        _state.copyWith(isLoading: false, errorMessage: e.toString()),
      );
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<Result<void>> _refreshToken() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    final result = await _authOperationsUseCase.refreshToken();
    result.when(
      ok: (response) {
        _logger.info('[AuthViewModel] Token renovado com sucesso');
        checkAuthStatusCommand.execute();
      },
      error: (error) {
        _updateState(
          _state.copyWith(isLoading: false, errorMessage: error.toString()),
        );
      },
    );
    _updateState(_state.copyWith(isLoading: false));
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

  Future<webview.NavigationDecision> handleWebViewNavigation(String url) async {
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

  Future<Result<AuthState>> reset() async {
    _updateState(AuthViewState.initial());
    return Result.ok(AuthState.initial);
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }
}
