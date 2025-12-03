import 'package:flutter/foundation.dart';

import '../../service/http_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  final HttpService _httpService;
  final AppLogger _logger;

  bool _isLoading = false;
  String? _errorMessage;
  bool _resetSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get resetSuccess => _resetSuccess;

  ResetPasswordViewModel(
    this._httpService,
    this._logger,
  );

  Future<Result<void>> resetPassword(
    String email,
    String token,
    String password,
  ) async {
    try {
      _resetSuccess = false;
      _setLoading(true);
      _clearError();

      // Validação básica
      if (email.isEmpty || token.isEmpty || password.isEmpty) {
        _setError('All fields are required');
        return Result.error(
          Exception('All fields are required'),
        );
      }

      if (token.length != 6) {
        _setError('Please enter a valid 6-character code');
        return Result.error(
          Exception('Invalid token length'),
        );
      }

      // Chamada à API de reset de senha
      final response = await _httpService.post(
        '/auth/password/reset',
        data: {
          'token': token,
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      // Processar resposta
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        _setError('Unexpected response from server.');
        return Result.error(
          Exception('Unexpected password reset response format'),
        );
      }

      if (data['success'] == true) {
        _resetSuccess = true;
        _setLoading(false);
        return Result.ok(null);
      } else {
        final errorMsg =
            data['message'] ?? data['error'] ?? 'Password reset failed';
        _setError(errorMsg);
        return Result.error(
          Exception(errorMsg),
        );
      }
    } catch (e, stack) {
      _logger.error('[ResetPasswordViewModel] Password reset error', e, stack);

      String errorMsg = 'Unable to reset password. Please try again.';

      // Verificar tipos específicos de erro
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('400') || errorStr.contains('invalid')) {
        errorMsg = 'Invalid or expired code. Please request a new code.';
      } else if (errorStr.contains('404')) {
        errorMsg = 'Reset code not found. Please request a new code.';
      } else if (errorStr.contains('422') || errorStr.contains('validation')) {
        errorMsg = 'Invalid data. Please check your information.';
      } else if (errorStr.contains('429') || errorStr.contains('too many')) {
        errorMsg = 'Too many attempts. Please try again later.';
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
