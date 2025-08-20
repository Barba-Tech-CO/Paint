import 'package:flutter/material.dart';

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
  
  String get displayName {
    if (_isLoading) return 'User';
    if (_error != null) return 'User'; // Fallback when there's an error
    return _user?.name ?? 'User';
  }
  bool get isGhlUser => _user?.isGhlUser ?? false;
  BusinessInfo? get businessInfo => _user?.businessInfo;

  Future<void> fetchUser() async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await _userService.getUser();
      
      if (result is Ok<UserModel>) {
        _user = result.asOk.value;
        _logger.info('User data fetched successfully: ${_user?.name}');
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
}