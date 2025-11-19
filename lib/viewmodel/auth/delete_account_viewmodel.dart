import 'package:flutter/foundation.dart';

import '../../service/auth_service.dart';
import '../../service/auth_state_manager.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class DeleteAccountViewModel extends ChangeNotifier {
  final AuthService _authService;
  final AuthStateManager _authStateManager;
  final AppLogger _logger;

  bool _isLoading = false;
  String? _errorMessage;
  bool _deletionSuccess = false;
  bool _showConfirmation = false;
  String? _pendingPassword;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get deletionSuccess => _deletionSuccess;
  bool get showConfirmation => _showConfirmation;

  DeleteAccountViewModel(
    this._authService,
    this._authStateManager,
    this._logger,
  );

  void requestDeleteAccount(String password) {
    if (password.isEmpty) {
      _setError('Password is required');
      return;
    }

    _pendingPassword = password;
    _showConfirmation = true;
    notifyListeners();
  }

  void cancelDeletion() {
    _showConfirmation = false;
    _pendingPassword = null;
    notifyListeners();
  }

  Future<Result<void>> confirmDeleteAccount() async {
    if (_pendingPassword == null) {
      return Result.error(Exception('No password provided'));
    }

    _showConfirmation = false;
    notifyListeners();

    return deleteAccount(_pendingPassword!);
  }

  Future<Result<void>> deleteAccount(String password) async {
    try {
      _deletionSuccess = false;
      _setLoading(true);
      _clearError();

      if (password.isEmpty) {
        _setError('Password is required');
        return Result.error(
          Exception('Password is required'),
        );
      }

      final result = await _authService.deleteAccount(password);

      return result.when(
        ok: (_) async {
          _logger.info('[DeleteAccountViewModel] Account deletion successful');
          await _authStateManager.logout();
          _deletionSuccess = true;
          _setLoading(false);
          return Result.ok(null);
        },
        error: (error) {
          _logger.error(
            '[DeleteAccountViewModel] Account deletion failed: $error',
          );

          String errorMsg = 'Failed to delete account. Please try again.';

          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('invalid password')) {
            errorMsg = 'Invalid password. Please try again.';
          } else if (errorStr.contains('unauthorized') ||
              errorStr.contains('401')) {
            errorMsg = 'Invalid password. Please verify and try again.';
          } else if (errorStr.contains('network') ||
              errorStr.contains('connection')) {
            errorMsg = 'Network error. Please check your connection.';
          } else if (errorStr.contains('timeout')) {
            errorMsg = 'Request timeout. Please try again.';
          }

          _setError(errorMsg);
          return Result.error(error);
        },
      );
    } catch (e, stack) {
      _logger.error(
        '[DeleteAccountViewModel] Unexpected error during account deletion',
        e,
        stack,
      );

      _setError('An unexpected error occurred. Please try again.');
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
