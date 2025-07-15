import 'dart:async';

import 'package:flutter/material.dart';

import 'package:paintpro/utils/logger/app_logger.dart';

import '../../config/dependency_injection.dart';
import '../../model/auth_model.dart';
import '../../service/auth_service.dart';
import '../../service/deep_link_service.dart';
import '../../utils/result/result.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  final DeepLinkService _deepLinkService;
  final AppLogger _logger;
  StreamSubscription? _deepLinkSubscription;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  AuthModel? _authStatus;

  AuthViewModel(this._authService, this._logger)
    : _deepLinkService = getIt<DeepLinkService>() {
    _initializeDeepLinkListener();
  }

  // Getters
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  AuthModel? get authStatus => _authStatus;

  /// Inicializa o listener de Deep Links
  void _initializeDeepLinkListener() {
    _deepLinkSubscription = _deepLinkService.deepLinkStream.listen(
      (uri) {
        _logger.info('[AuthViewModel] Deep Link recebido: $uri');
        if (uri.pathSegments.contains('success')) {
          _handleAuthSuccess();
        } else if (uri.pathSegments.contains('error')) {
          final error = uri.queryParameters['error'];
          _handleAuthError(error ?? 'Erro desconhecido na autenticação');
        }
      },
      onError: (error) {
        _logger.error('[AuthViewModel] Erro no Deep Link', error);
        _handleAuthError('Erro ao processar callback de autenticação');
      },
    );
  }

  /// Verifica o status de autenticação
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.getStatus();
      if (result is Ok) {
        final status = result.asOk.value;
        _authStatus = status.data;
        _isAuthenticated = status.data.authenticated && !status.data.needsLogin;
        _logger.info(
          '[AuthViewModel] Status de autenticação:  [32m$_isAuthenticated [0m',
        );
      } else {
        _handleAuthError('Erro ao verificar status de autenticação');
      }
    } catch (e, stack) {
      _logger.error('[AuthViewModel] Erro ao verificar status', e, stack);
      _handleAuthError('Erro ao verificar status: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém a URL de autorização
  Future<String?> getAuthorizeUrl() async {
    // Não chama _setLoading aqui para evitar problemas durante o build
    try {
      final result = await _authService.getAuthorizeUrl();
      if (result is Ok) {
        final url = result.asOk.value;
        _logger.info('[AuthViewModel] URL de autorização obtida: $url');
        return url;
      } else {
        _handleAuthError('Erro ao obter URL de autorização');
        return null;
      }
    } catch (e, stack) {
      _logger.error(
        '[AuthViewModel] Erro ao obter URL de autorização',
        e,
        stack,
      );
      _handleAuthError('Erro ao obter URL de autorização: $e');
      return null;
    }
  }

  /// Processa o callback de autorização
  Future<void> processCallback(String code) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.processCallback(code);
      if (result is Ok) {
        _logger.info('[AuthViewModel] Callback processado com sucesso');
        await checkAuthStatus(); // Atualiza o status após o callback
      } else {
        _handleAuthError('Erro ao processar callback');
      }
    } catch (e, stack) {
      _logger.error('[AuthViewModel] Erro ao processar callback', e, stack);
      _handleAuthError('Erro ao processar callback: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Renova o token de acesso
  Future<void> refreshToken() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.refreshToken();
      if (result is Ok) {
        _logger.info('[AuthViewModel] Token renovado com sucesso');
        await checkAuthStatus(); // Atualiza o status após renovação
      } else {
        _handleAuthError('Erro ao renovar token');
      }
    } catch (e, stack) {
      _logger.error('[AuthViewModel] Erro ao renovar token', e, stack);
      _handleAuthError('Erro ao renovar token: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Verifica se o token está próximo de expirar
  Future<bool> isTokenExpiringSoon() async {
    try {
      final result = await _authService.isTokenExpiringSoon();
      if (result is Ok) {
        return result.asOk.value;
      }
      return true; // Em caso de erro, assume que está expirando
    } catch (e, stack) {
      _logger.error(
        '[AuthViewModel] Erro ao verificar expiração do token',
        e,
        stack,
      );
      return true;
    }
  }

  /// Manipula sucesso na autenticação via Deep Link
  void _handleAuthSuccess() {
    _logger.info('[AuthViewModel] Autenticação bem-sucedida via Deep Link!');
    _clearError();
    // Atualiza o status de autenticação
    checkAuthStatus();
  }

  /// Manipula erro na autenticação
  void _handleAuthError(String error) {
    _logger.error('[AuthViewModel] Erro na autenticação: $error');
    _errorMessage = error;
    _isAuthenticated = false;
    notifyListeners();
  }

  /// Define o estado de carregamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Limpa mensagens de erro
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa recursos
  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  void setLoading(bool loading) => _setLoading(loading);
  void clearError() => _clearError();
  void handleError(String error) => _handleAuthError(error);
}
