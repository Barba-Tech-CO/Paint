import 'dart:async';

import '../config/dependency_injection.dart';
import '../utils/logger/app_logger.dart';
import 'auth_persistence_service.dart';
import 'http_service.dart';

/// Global authentication state manager that coordinates auth state across the app
class AuthStateManager {
  static final AuthStateManager _instance = AuthStateManager._internal();
  factory AuthStateManager() => _instance;
  AuthStateManager._internal();

  late final AppLogger _logger;
  late final AuthPersistenceService _authPersistenceService;
  late final HttpService _httpService;

  // Stream controller for authentication state changes
  final StreamController<bool> _authStateController =
      StreamController<bool>.broadcast();

  // Current authentication state
  bool _isAuthenticated = false;

  // Callbacks for authentication state changes
  final List<void Function()> _onAuthFailureCallbacks = [];
  final List<void Function()> _onAuthSuccessCallbacks = [];

  /// Stream of authentication state changes
  Stream<bool> get authStateStream => _authStateController.stream;

  /// Current authentication state
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize the auth state manager
  Future<void> initialize() async {
    try {
      // Initialize dependencies
      _logger = getIt<AppLogger>();
      _authPersistenceService = getIt<AuthPersistenceService>();
      _httpService = getIt<HttpService>();

      _isAuthenticated = await _authPersistenceService.isUserAuthenticated();

      // Set up HTTP service auth failure callback
      _httpService.setAuthFailureCallback(_handleAuthFailure);

      _authStateController.add(_isAuthenticated);
    } catch (e) {
      _logger.error('[AuthStateManager] Error initializing: $e');
      _isAuthenticated = false;
      _authStateController.add(false);
    }
  }

  /// Handle authentication failure (token expiration, etc.)
  void _handleAuthFailure() {
    _isAuthenticated = false;
    _authStateController.add(false);

    // Notify all registered callbacks  
    for (final callback in _onAuthFailureCallbacks) {
      try {
        callback();
      } catch (e) {
        _logger.error('[AuthStateManager] Error in auth failure callback: $e');
      }
    }
  }

  /// Handle successful authentication
  void handleAuthSuccess() {
    _isAuthenticated = true;
    _authStateController.add(true);

    // Notify all registered callbacks
    for (final callback in _onAuthSuccessCallbacks) {
      try {
        callback();
      } catch (e) {
        _logger.error('[AuthStateManager] Error in auth success callback: $e');
      }
    }
  }

  /// Register a callback for authentication failure
  void onAuthFailure(void Function() callback) {
    _onAuthFailureCallbacks.add(callback);
  }

  /// Register a callback for authentication success
  void onAuthSuccess(void Function() callback) {
    _onAuthSuccessCallbacks.add(callback);
  }

  /// Remove a callback for authentication failure
  void removeAuthFailureCallback(void Function() callback) {
    _onAuthFailureCallbacks.remove(callback);
  }

  /// Remove a callback for authentication success
  void removeAuthSuccessCallback(void Function() callback) {
    _onAuthSuccessCallbacks.remove(callback);
  }

  /// Check if user is currently authenticated
  Future<bool> checkAuthenticationStatus() async {
    try {
      final isAuth = await _authPersistenceService.isUserAuthenticated();
      if (_isAuthenticated != isAuth) {
        _isAuthenticated = isAuth;
        _authStateController.add(isAuth);
      }
      return isAuth;
    } catch (e) {
      _logger.error('[AuthStateManager] Error checking auth status: $e');
      return false;
    }
  }

  /// Force logout and clear all auth state
  Future<void> logout() async {
    try {
      await _authPersistenceService.clearAuthState();
      _httpService.clearAuthToken();
      _handleAuthFailure();
    } catch (e) {
      _logger.error('[AuthStateManager] Error during logout: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
    _onAuthFailureCallbacks.clear();
    _onAuthSuccessCallbacks.clear();
  }
}
