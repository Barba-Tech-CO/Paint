import 'dart:async';

import 'package:flutter/material.dart';

import 'package:paintpro/utils/logger/app_logger.dart';
import 'package:webview_flutter/webview_flutter.dart' as webview;

import '../../config/dependency_injection.dart';
import '../../model/auth_model.dart';
import '../../model/auth_state.dart';
import '../../service/deep_link_service.dart';
import '../../use_case/auth/auth_use_cases.dart';
import '../../utils/result/result.dart';
import 'auth_view_state.dart';
import '../../utils/command/command.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthOperationsUseCase _authOperationsUseCase;
  final HandleDeepLinkUseCase _handleDeepLinkUseCase;
  final HandleWebViewNavigationUseCase _handleWebViewNavigationUseCase;
  final DeepLinkService _deepLinkService;
  final AppLogger _logger;
  StreamSubscription? _deepLinkSubscription;

  AuthViewState _state = AuthViewState.initial();
  AuthViewState get state => _state;

  static const String ghlAuthorizeUrl =
      'https://marketplace.gohighlevel.com/oauth/chooselocation?response_type=code&redirect_uri=https%3A%2F%2Fpaintpro.barbatech.company%2Fapi%2Foauth%2Fcallback&client_id=6845ab8de6772c0d5c8548d7-mbnty1f6&scope=contacts.write+associations.write+associations.readonly+oauth.readonly+oauth.write+invoices%2Festimate.write+invoices%2Festimate.readonly+invoices.readonly+associations%2Frelation.write+associations%2Frelation.readonly+contacts.readonly+invoices.write';

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
    this._logger,
  ) : _deepLinkService = getIt<DeepLinkService>() {
    _initializeDeepLinkListener();
    _initializeAuth();
  }

  void _updateState(AuthViewState newState) {
    _state = newState;
    notifyListeners();
  }

  void _initializeAuth() {
    _updateState(_state.copyWith(authorizeUrl: ghlAuthorizeUrl));
    // Executar o comando para que a tela mostre o conteúdo
    checkAuthStatusCommand.execute();
  }

  void _initializeDeepLinkListener() {
    _deepLinkSubscription = _deepLinkService.deepLinkStream.listen(
      (uri) {
        _logger.info('[AuthViewModel] Deep Link recebido: $uri');
        if (uri.pathSegments.contains('success')) {
          _handleDeepLinkUseCase.handleSuccess();
        } else if (uri.pathSegments.contains('error')) {
          final error = uri.queryParameters['error'];
          _handleDeepLinkUseCase.handleError(
            error ?? 'Erro desconhecido na autenticação',
          );
        }
      },
      onError: (error) {
        _logger.error('[AuthViewModel] Erro no Deep Link', error);
        _handleDeepLinkUseCase.handleGenericError();
      },
    );
  }

  // Métodos privados para os comandos
  Future<Result<AuthModel>> _checkAuthStatus() async {
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    final result = await _authOperationsUseCase.checkAuthStatus();
    result.when(
      ok: (authModel) {
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
    _updateState(_state.copyWith(isLoading: true, errorMessage: null));
    final result = await _authOperationsUseCase.processCallback(code);
    result.when(
      ok: (response) {
        _logger.info('[AuthViewModel] Callback processado com sucesso');
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
    _deepLinkSubscription?.cancel();
    super.dispose();
  }
}
