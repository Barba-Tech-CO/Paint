import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class AuthPersistenceService {
  static const String _keyAuthenticated = 'auth_authenticated';
  static const String _keyNeedsLogin = 'auth_needs_login';
  static const String _keyLocationId = 'auth_location_id';
  static const String _keyExpiresAt = 'auth_expires_at';
  static const String _keySanctumToken = 'auth_sanctum_token';

  // Save authentication state
  Future<void> saveAuthState({
    required bool authenticated,
    required bool needsLogin,
    String? locationId,
    DateTime? expiresAt,
    String? sanctumToken,
  }) async {
    log(
      '[AuthPersistenceService] Saving auth state: authenticated=$authenticated, needsLogin=$needsLogin, locationId=$locationId, expiresAt=$expiresAt',
    );

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

    log('[AuthPersistenceService] Auth state saved successfully');
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

    log('[AuthPersistenceService] Loaded auth state: $state');
    return state;
  }

  // Clear authentication state (logout)
  Future<void> clearAuthState() async {
    log('[AuthPersistenceService] Clearing auth state');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthenticated);
    await prefs.remove(_keyNeedsLogin);
    await prefs.remove(_keyLocationId);
    await prefs.remove(_keyExpiresAt);
    await prefs.remove(_keySanctumToken);
    log('[AuthPersistenceService] Auth state cleared');
  }

  // Check if user should be considered authenticated based on stored data
  Future<bool> isUserAuthenticated() async {
    final state = await loadAuthState();
    final authenticated = state['authenticated'] as bool;
    final needsLogin = state['needsLogin'] as bool;

    log(
      '[AuthPersistenceService] Checking if user authenticated: authenticated=$authenticated, needsLogin=$needsLogin',
    );

    // For now, ignore expiration since backend provides incorrect dates
    // Just check if user was authenticated and doesn't need login
    final result = authenticated && !needsLogin;
    log('[AuthPersistenceService] User authenticated result: $result');
    return result;
  }

  // Get stored Sanctum token
  Future<String?> getSanctumToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySanctumToken);
  }
}
