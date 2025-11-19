import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

class AuthPersistenceService {
  static const String _keyAuthenticated = 'auth_authenticated';
  static const String _keyNeedsLogin = 'auth_needs_login';
  static const String _keyLocationId = 'auth_location_id';
  static const String _keyExpiresAt = 'auth_expires_at';
  static const String _keySanctumToken = 'auth_sanctum_token';

  final AppLogger _logger = LoggerAppLoggerImpl();

  // Save authentication state
  Future<void> saveAuthState({
    required bool authenticated,
    required bool needsLogin,
    String? locationId,
    DateTime? expiresAt,
    String? sanctumToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAuthenticated, authenticated);
    await prefs.setBool(_keyNeedsLogin, needsLogin);

    if (locationId != null) {
      await prefs.setString(_keyLocationId, locationId);
    }

    if (expiresAt != null) {
      await prefs.setString(_keyExpiresAt, expiresAt.toIso8601String());
    }

    if (sanctumToken != null) {
      await prefs.setString(_keySanctumToken, sanctumToken);
    }
  }

  // Load authentication state
  Future<Map<String, dynamic>> loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();

    final authenticated = prefs.getBool(_keyAuthenticated) ?? false;
    final needsLogin = prefs.getBool(_keyNeedsLogin) ?? true;
    final locationId = prefs.getString(_keyLocationId);
    final sanctumToken = prefs.getString(_keySanctumToken);

    DateTime? expiresAt;
    final expiresAtString = prefs.getString(_keyExpiresAt);
    if (expiresAtString != null) {
      try {
        expiresAt = DateTime.parse(expiresAtString);
      } catch (e) {
        // Invalid date format, ignore
      }
    }

    final state = {
      'authenticated': authenticated,
      'needsLogin': needsLogin,
      'locationId': locationId,
      'expiresAt': expiresAt,
      'sanctumToken': sanctumToken,
    };

    return state;
  }

  // Clear authentication state (logout)
  Future<void> clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthenticated);
    await prefs.remove(_keyNeedsLogin);
    await prefs.remove(_keyLocationId);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keySanctumToken);
  }

  // Check if user should be considered authenticated based on stored data
  Future<bool> isUserAuthenticated() async {
    final state = await loadAuthState();
    final authenticated = state['authenticated'] as bool;
    final needsLogin = state['needsLogin'] as bool;
    final expiresAt = state['expiresAt'] as DateTime?;

    // Check if token has expired
    if (expiresAt != null) {
      final now = DateTime.now();
      if (expiresAt.isBefore(now)) {
        _logger.warning(
          '[AuthPersistenceService] Token expired, clearing auth state',
        );
        // Clear expired authentication state
        await clearAuthState();
        return false;
      }
    }

    // Check if user was authenticated and doesn't need login
    final result = authenticated && !needsLogin;
    return result;
  }

  // Get stored Sanctum token
  Future<String?> getSanctumToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_keySanctumToken);
      return token;
    } catch (e) {
      _logger.error('[AuthPersistenceService] Error getting token: $e');
      return null;
    }
  }

  // Check if token is expired without clearing the state
  Future<bool> isTokenExpired() async {
    final state = await loadAuthState();
    final expiresAt = state['expiresAt'] as DateTime?;

    if (expiresAt == null) {
      return false;
    }

    final now = DateTime.now();
    final isExpired = expiresAt.isBefore(now);

    return isExpired;
  }

  // Force logout by clearing all authentication data
  Future<void> forceLogout() async {
    await clearAuthState();
  }
}
