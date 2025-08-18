import 'package:flutter/widgets.dart';
import '../../../../core/config/dependency_injection.dart';
import '../../../../service/app_initialization_service.dart';
import '../../../../service/navigation_service.dart';

class InitializeAppUsecase {
  Future<void> execute(BuildContext context) async {
    // Aguarda um pouco para mostrar a animação
    await Future.delayed(const Duration(seconds: 2));

    // Usa o serviço de inicialização já configurado na injeção de dependências
    final appInitService = getIt<AppInitializationService>();

    try {
      await appInitService.initializeApp(context);
    } catch (e) {
      // Em caso de erro, vai para autenticação
      final navigationService = getIt<NavigationService>();
      navigationService.navigateToAuth(context);
    }
  }
}