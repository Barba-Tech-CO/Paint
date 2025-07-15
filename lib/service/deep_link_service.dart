import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _subscription;
  final StreamController<Uri> _deepLinkController =
      StreamController<Uri>.broadcast();

  /// Stream para receber Deep Links
  Stream<Uri> get deepLinkStream => _deepLinkController.stream;

  /// Inicializa o serviço de Deep Links
  Future<void> initialize() async {
    if (kIsWeb) return; // Deep Links não funcionam na web

    try {
      // Listener para quando o app está em segundo plano e é reaberto pelo link
      _subscription = _appLinks.uriLinkStream.listen(
        (uri) {
          log('[DeepLinkService] Deep Link recebido: $uri');
          _processDeepLink(uri);
        },
        onError: (err) {
          log('[DeepLinkService] Erro ao processar Deep Link: $err');
        },
      );

      log('[DeepLinkService] Serviço inicializado com sucesso');
    } catch (e) {
      log('[DeepLinkService] Erro ao inicializar serviço: $e');
    }
  }

  /// Processa um Deep Link recebido
  void _processDeepLink(Uri uri) {
    if (uri.scheme == 'paintproapp' && uri.host == 'auth') {
      if (uri.pathSegments.contains('success')) {
        log('[DeepLinkService] Autenticação bem-sucedida via Deep Link!');
        _deepLinkController.add(uri);
      } else if (uri.pathSegments.contains('error')) {
        log('[DeepLinkService] Erro na autenticação via Deep Link');
        _deepLinkController.add(uri);
      }
    }
  }

  /// Gera URL de callback para Deep Link
  String generateCallbackUrl() {
    return 'paintproapp://auth/success';
  }

  /// Gera URL de erro para Deep Link
  String generateErrorUrl([String? error]) {
    final errorParam = error != null ? '?error=$error' : '';
    return 'paintproapp://auth/error$errorParam';
  }

  /// Dispara um Deep Link para o próprio app (para testes)
  void triggerDeepLink(String path) {
    final uri = Uri.parse('paintproapp://auth/$path');
    _processDeepLink(uri);
  }

  /// Dispara o callback de sucesso
  void triggerSuccessCallback() {
    triggerDeepLink('success');
  }

  /// Dispara o callback de erro
  void triggerErrorCallback([String? error]) {
    final path = error != null ? 'error?error=$error' : 'error';
    triggerDeepLink(path);
  }

  /// Libera recursos
  void dispose() {
    _subscription?.cancel();
    _deepLinkController.close();
  }
}
