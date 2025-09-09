import 'package:flutter/material.dart';

import '../utils/result/result.dart';
import 'auth_persistence_service.dart';
import 'auth_service.dart';
import 'deep_link_service.dart';
import 'navigation_service.dart';

class AppInitializationService {
  final AuthService _authService;
  final AuthPersistenceService _authPersistenceService;
  final NavigationService _navigationService;
  final DeepLinkService _deepLinkService;

  AppInitializationService(
    this._authService,
    this._authPersistenceService,
    this._navigationService,
    this._deepLinkService,
  );

  /// Inicializa a aplicação e determina para onde navegar
  Future<void> initializeApp(BuildContext context) async {
    // Inicializa o serviço de Deep Links
    await _deepLinkService.initialize();

    // First check local persistence for token expiration
    final isLocallyAuthenticated = await _authPersistenceService
        .isUserAuthenticated();

    if (!isLocallyAuthenticated) {
      // Token expired or no local authentication, go to auth
      if (context.mounted) {
        _navigationService.navigateToAuth(context);
      }
      return;
    }

    // If locally authenticated, verify with backend
    final authResult = await _authService.isAuthenticated();

    if (authResult is Ok) {
      final authenticated = authResult.asOk.value;
      if (authenticated) {
        if (context.mounted) {
          _navigationService.navigateToDashboard(context);
        }
      } else {
        if (context.mounted) {
          _navigationService.navigateToAuth(context);
        }
      }
    } else {
      // Em caso de erro, vai para autenticação
      if (context.mounted) {
        _navigationService.navigateToAuth(context);
      }
    }
  }

  /// Verifica se o usuário está autenticado
  Future<Result<bool>> checkAuthenticationStatus() async {
    return await _authService.isAuthenticated();
  }
}
