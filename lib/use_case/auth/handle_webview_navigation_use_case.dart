import 'package:webview_flutter/webview_flutter.dart';

/// UseCase para lidar com navegação do WebView
class HandleWebViewNavigationUseCase {
  HandleWebViewNavigationUseCase();

  /// Processa decisão de navegação
  Future<NavigationDecision> handleNavigation(
    String url,
    Function(String) setErrorCallback,
    Function(String) processCallback,
  ) async {
    if (url.contains('code=')) {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        await processCallback(code);
      } else {
        setErrorCallback(
          'Código de autorização não encontrado na URL de callback.',
        );
      }
      return NavigationDecision.prevent;
    }

    if (url.contains('error=')) {
      final uri = Uri.parse(url);
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];
      setErrorCallback(errorDescription ?? error ?? 'Erro na autorização');
      return NavigationDecision.prevent;
    }

    if (url.startsWith('https://app.gohighlevel.com/?src=marketplace')) {
      return NavigationDecision.prevent; // Será tratado pela view
    }

    if (url.startsWith('https://marketplace.gohighlevel.com') ||
        url.startsWith('https://app.gohighlevel.com') ||
        url.startsWith('https://highlevel-backend.firebaseapp.com')) {
      return NavigationDecision.navigate;
    }

    return NavigationDecision.navigate;
  }
}
