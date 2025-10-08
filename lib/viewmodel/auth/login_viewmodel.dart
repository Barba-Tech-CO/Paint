import 'package:flutter/foundation.dart';

import '../../service/auth_persistence_service.dart';
import '../../service/http_service.dart';
import '../../utils/auth/token_sanitizer.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class LoginViewModel extends ChangeNotifier {
  final HttpService _httpService;
  final AuthPersistenceService _authPersistenceService;
  final AppLogger _logger;

  bool _isLoading = false;
  String? _errorMessage;
  bool _loginSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get loginSuccess => _loginSuccess;

  LoginViewModel(
    this._httpService,
    this._authPersistenceService,
    this._logger,
  );

  Future<Result<void>> login(String email, String password) async {
    try {
      _loginSuccess = false;
      _setLoading(true);
      _clearError();

      // Validação básica
      if (email.isEmpty || password.isEmpty) {
        _setError('Email and password are required');
        return Result.error(
          Exception('Email and password are required'),
        );
      }

      // Chamada à API de login
      final response = await _httpService.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'device_name': 'mobile_app',
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        _setError('Unexpected response from server.');
        return Result.error(
          Exception('Unexpected login response format'),
        );
      }

      if (data['success'] == true) {
        final rawToken =
            data['auth_token'] ?? data['sanctum_token'] ?? data['token'];

        final sanitizedToken = TokenSanitizer.sanitizeToken(rawToken);
        if (sanitizedToken == null) {
          _setError('Authentication failed. Invalid token received.');
          return Result.error(
            Exception('Invalid token received'),
          );
        }

        _httpService.setAuthToken(sanitizedToken);

        await _authPersistenceService.saveAuthState(
          authenticated: true,
          needsLogin: false,
          expiresAt: null,
          sanctumToken: sanitizedToken,
        );

        _logger.info('[LoginViewModel] Login successful');
        _loginSuccess = true;
        _setLoading(false);
        return Result.ok(null);
      } else {
        final errorMsg = data['message'] ?? data['error'] ?? 'Login failed';
        _setError(errorMsg);
        return Result.error(
          Exception(errorMsg),
        );
      }
    } catch (e, stack) {
      _logger.error('[LoginViewModel] Login error', e, stack);

      String errorMsg = 'Unable to login. Please try again.';

      // Verificar tipos específicos de erro
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
        errorMsg = 'Invalid email or password';
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        errorMsg = 'Network error. Please check your connection.';
      } else if (errorStr.contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
      }

      _setError(errorMsg);
      return Result.error(
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
