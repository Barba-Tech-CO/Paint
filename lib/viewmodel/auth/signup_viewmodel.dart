import 'package:flutter/foundation.dart';

import '../../model/user_model.dart';
import '../../service/auth_persistence_service.dart';
import '../../service/http_service.dart';
import '../../service/location_service.dart';
import '../../service/user_service.dart';
import '../../utils/auth/token_sanitizer.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class SignUpViewModel extends ChangeNotifier {
  final HttpService _httpService;
  final AuthPersistenceService _authPersistenceService;
  final LocationService _locationService;
  final UserService _userService;
  final AppLogger _logger;

  bool _isLoading = false;
  String? _errorMessage;
  bool _signUpSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get signUpSuccess => _signUpSuccess;

  SignUpViewModel(
    this._httpService,
    this._authPersistenceService,
    this._locationService,
    this._userService,
    this._logger,
  );

  Future<Result<void>> signUp(
    String name,
    String email,
    String password,
  ) async {
    try {
      _signUpSuccess = false;
      _setLoading(true);
      _clearError();

      // Validação básica
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _setError('All fields are required');
        return Result.error(Exception('All fields are required'));
      }

      // Chamada à API de registro
      final response = await _httpService.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      // Processar resposta
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        _setError('Unexpected response from server.');
        return Result.error(
          Exception('Unexpected registration response format'),
        );
      }

      if (data['success'] == true) {
        final rawToken =
            data['auth_token'] ?? data['sanctum_token'] ?? data['token'];

        final sanitizedToken = TokenSanitizer.sanitizeToken(rawToken);
        if (sanitizedToken == null) {
          _setError('Registration failed. No token received.');
          return Result.error(Exception('No token received'));
        }

        _httpService.setAuthToken(sanitizedToken);

        String? locationId = data['location_id'] ?? data['locationId'];

        try {
          final userResult = await _userService.getUser();
          if (userResult is Ok<UserModel>) {
            final user = userResult.asOk.value;
            final userLocationId = user.ghlLocationId;
            if (userLocationId != null && userLocationId.isNotEmpty) {
              locationId = userLocationId;
              _locationService.setLocationId(userLocationId);
            } else {
              _locationService.clearLocationId();
            }
          } else if (locationId != null && locationId.isNotEmpty) {
            final resolvedLocation = locationId;
            _locationService.setLocationId(resolvedLocation);
          }
        } catch (e) {
          _logger.warning(
            '[SignUpViewModel] Unable to fetch user after registration: $e',
          );
          if (locationId != null && locationId.isNotEmpty) {
            final resolvedLocation = locationId;
            _locationService.setLocationId(resolvedLocation);
          } else {
            _locationService.clearLocationId();
          }
        }

        await _authPersistenceService.saveAuthState(
          authenticated: true,
          needsLogin: false,
          expiresAt: null,
          locationId: locationId,
          sanctumToken: sanitizedToken,
        );

        _logger.info('[SignUpViewModel] Sign up successful');
        _signUpSuccess = true;
        _setLoading(false);
        return Result.ok(null);
      } else {
        final errorMsg =
            data['message'] ?? data['error'] ?? 'Registration failed';
        _setError(errorMsg);
        return Result.error(Exception(errorMsg));
      }
    } catch (e, stack) {
      _logger.error('[SignUpViewModel] Sign up error', e, stack);

      String errorMsg = 'Unable to create account. Please try again.';

      // Verificar tipos específicos de erro
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('409') ||
          errorStr.contains('conflict') ||
          errorStr.contains('already exists')) {
        errorMsg = 'Email already registered. Please login instead.';
      } else if (errorStr.contains('422') || errorStr.contains('validation')) {
        errorMsg = 'Invalid data. Please check your information.';
      } else if (errorStr.contains('network') ||
          errorStr.contains('connection')) {
        errorMsg = 'Network error. Please check your connection.';
      } else if (errorStr.contains('timeout')) {
        errorMsg = 'Request timeout. Please try again.';
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
