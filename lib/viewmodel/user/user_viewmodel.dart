import 'package:flutter/material.dart';

import '../../model/business_info_model.dart';
import '../../model/user_model.dart';
import '../../service/user_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService;
  final AppLogger _logger;

  UserViewModel(this._userService, this._logger);

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get displayName => _user?.name ?? '';

  bool get isGhlUser => _user?.isGhlUser ?? false;
  BusinessInfoModel? get businessInfo => _user?.businessInfo;

  // New properties for special GHL states
  bool get hasGhlDataIncomplete => _user?.ghlDataIncomplete ?? false;
  bool get hasGhlError => _user?.ghlError ?? false;

  // Helper property to check if user has any GHL issues
  bool get hasGhlIssues => hasGhlDataIncomplete || hasGhlError;

  Future<void> fetchUser() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _userService.getUser();

      if (result is Ok<UserModel>) {
        _user = result.asOk.value;
        _logger.info('User data fetched successfully: ${_user?.name}');

        // Log special GHL states for debugging and user awareness
        if (_user?.ghlDataIncomplete == true) {
          _logger.warning(
            'User has incomplete GHL data - some features may be limited',
          );
        }

        if (_user?.ghlError == true) {
          _logger.warning(
            'User has GHL error - integration may not be working properly',
          );
        }
      } else if (result is Error<UserModel>) {
        final errorMessage = result.asError.error.toString();
        _setError(errorMessage);
        _logger.error('Failed to fetch user data: $errorMessage');
      }
    } catch (e) {
      final errorMessage = 'Unexpected error fetching user: $e';
      _setError(errorMessage);
      _logger.error(errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  /// Returns a user-friendly message for GHL issues
  String? getGhlIssueMessage() {
    if (!isGhlUser) return null;

    if (hasGhlError) {
      return 'There is an issue with your GoHighLevel integration. Some features may not work properly.';
    }

    if (hasGhlDataIncomplete) {
      return 'Your GoHighLevel data is incomplete. Please check your integration settings.';
    }

    return null;
  }

  /// Checks if the user can access GHL-specific features
  bool canAccessGhlFeatures() {
    return isGhlUser && !hasGhlError && !hasGhlDataIncomplete;
  }
}
