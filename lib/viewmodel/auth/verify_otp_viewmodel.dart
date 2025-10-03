import 'package:flutter/foundation.dart';

import '../../service/http_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class VerifyOtpViewModel extends ChangeNotifier {
  final HttpService _httpService;
  final AppLogger _logger;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _verificationSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get verificationSuccess => _verificationSuccess;

  VerifyOtpViewModel(
    this._httpService,
    this._logger,
  );

  Future<Result<void>> verifyOtp(String email, String code) async {
    try {
      _setLoading(true);
      _clearMessages();

      // Validação básica
      if (email.isEmpty || code.isEmpty) {
        _setError('Email and code are required');
        return Result.error(Exception('Email and code are required'));
      }

      if (code.length != 6) {
        _setError('Please enter a valid 6-digit code');
        return Result.error(Exception('Invalid code length'));
      }

      // Chamada à API de verificação OTP
      final response = await _httpService.post(
        '/auth/verify-otp',
        data: {
          'email': email,
          'code': code,
        },
      );

      // Processar resposta
      if (response.data['success'] == true) {
        _logger.info('[VerifyOtpViewModel] OTP verification successful');
        _verificationSuccess = true;
        _setLoading(false);
        return Result.ok(null);
      } else {
        final errorMsg = response.data['message'] ??
                        response.data['error'] ??
                        'Verification failed';
        _setError(errorMsg);
        return Result.error(Exception(errorMsg));
      }
    } catch (e, stack) {
      _logger.error('[VerifyOtpViewModel] OTP verification error', e, stack);

      String errorMsg = 'Unable to verify code. Please try again.';

      // Verificar tipos específicos de erro
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('400') || errorStr.contains('invalid')) {
        errorMsg = 'Invalid verification code. Please try again.';
      } else if (errorStr.contains('404') || errorStr.contains('expired')) {
        errorMsg = 'Code expired. Please request a new code.';
      } else if (errorStr.contains('429') || errorStr.contains('too many')) {
        errorMsg = 'Too many attempts. Please try again later.';
      } else if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMsg = 'Network error. Please check your connection.';
      } else if (errorStr.contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
      }

      _setError(errorMsg);
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  Future<Result<void>> resendCode(String email) async {
    try {
      _setLoading(true);
      _clearMessages();

      // Validação básica
      if (email.isEmpty) {
        _setError('Email is required');
        return Result.error(Exception('Email is required'));
      }

      // Chamada à API para reenviar código (usa endpoint de forgot password)
      final response = await _httpService.post(
        '/auth/password/forgot',
        data: {
          'email': email,
        },
      );

      // Processar resposta
      if (response.data['success'] == true) {
        _logger.info('[VerifyOtpViewModel] Code resent successfully');
        _setSuccess('Code sent! Check your email.');
        _setLoading(false);
        return Result.ok(null);
      } else {
        final errorMsg = response.data['message'] ??
                        response.data['error'] ??
                        'Failed to resend code';
        _setError(errorMsg);
        return Result.error(Exception(errorMsg));
      }
    } catch (e, stack) {
      _logger.error('[VerifyOtpViewModel] Resend code error', e, stack);

      String errorMsg = 'Unable to resend code. Please try again.';

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('429') || errorStr.contains('too many')) {
        errorMsg = 'Too many requests. Please wait a moment.';
      } else if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMsg = 'Network error. Please check your connection.';
      }

      _setError(errorMsg);
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _successMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setSuccess(String message) {
    _successMessage = message;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void clearMessages() {
    _clearMessages();
  }
}
