import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/dependency_injection.dart';
import '../utils/result/result.dart';
import 'auth_initialization_service.dart';
import 'auth_persistence_service.dart';
import 'auth_service.dart';
import 'auth_state_manager.dart';
import 'deep_link_service.dart';
import 'http_service.dart';

class AppInitializationService {
  final AuthService _authService;
  final AuthPersistenceService _authPersistenceService;
  final AuthStateManager _authStateManager;
  final DeepLinkService _deepLinkService;
  final HttpService _httpService;

  AppInitializationService(
    this._authService,
    this._authPersistenceService,
    this._authStateManager,
    this._deepLinkService,
    this._httpService,
  );

  /// Inicializa a aplicação e determina para onde navegar
  Future<void> initializeApp(BuildContext context) async {
    // Inicializa o serviço de Deep Links
    await _deepLinkService.initialize();

    // Initialize HTTP service with persisted token first
    await _httpService.initializeAuthToken();

    // Set up auth failure callback for automatic navigation BEFORE initializing AuthStateManager
    _authStateManager.onAuthFailure(() {
      if (context.mounted) {
        context.go('/auth');
      }
    });

    // Initialize AuthStateManager after callback is set up
    await _authStateManager.initialize();

    // Wait a moment for AuthViewModel to load persisted state
    await Future.delayed(const Duration(milliseconds: 100));

    // First check local persistence for token expiration
    final isLocallyAuthenticated = await _authPersistenceService
        .isUserAuthenticated();

    // Check if we have a token in HTTP service
    final hasHttpToken = _httpService.ghlToken != null;

    if (!isLocallyAuthenticated) {
      // Token expired or no local authentication, go to auth
      if (context.mounted) {
        context.go('/auth');
      }
      return;
    }

    // If locally authenticated and we have a token, go directly to dashboard
    // Skip backend verification during hot restart to avoid unnecessary network calls
    if (hasHttpToken) {
      await getIt<AuthInitializationService>().initializeUserData();

      if (context.mounted) {
        context.go('/home');
      }
      return;
    }

    // If locally authenticated but no token, verify with backend
    final authResult = await _authService.isAuthenticated();

    if (authResult is Ok) {
      final authenticated = authResult.asOk.value;

      if (authenticated) {
        // Initialize user data when authenticated
        await getIt<AuthInitializationService>().initializeUserData();

        if (context.mounted) {
          context.go('/home');
        }
      } else {
        if (context.mounted) {
          context.go('/auth');
        }
      }
    } else {
      // Em caso de erro, vai para autenticação
      if (context.mounted) {
        context.go('/auth');
      }
    }
  }

  /// Verifica se o usuário está autenticado
  Future<Result<bool>> checkAuthenticationStatus() async {
    return await _authService.isAuthenticated();
  }
}
