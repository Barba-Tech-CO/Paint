import 'package:flutter/material.dart';
import '../utils/result/result.dart';
import 'auth_service.dart';
import 'navigation_service.dart';

class AppInitializationService {
  final AuthService _authService;
  final NavigationService _navigationService;

  AppInitializationService(this._authService, this._navigationService);

  /// Inicializa a aplicação e determina para onde navegar
  Future<void> initializeApp(BuildContext context) async {
    final authResult = await _authService.isAuthenticated();

    if (authResult is Ok) {
      final authenticated = authResult.asOk.value;
      if (authenticated) {
        _navigationService.navigateToDashboard(context);
      } else {
        _navigationService.navigateToAuth(context);
      }
    } else {
      // Em caso de erro, vai para autenticação
      _navigationService.navigateToAuth(context);
    }
  }

  /// Verifica se o usuário está autenticado
  Future<Result<bool>> checkAuthenticationStatus() async {
    return await _authService.isAuthenticated();
  }
}
