import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import '../config/app_urls.dart';

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
    if (kIsWeb) return;

    try {
      // Listener para quando o app está em segundo plano e é reaberto pelo link
      _subscription = _appLinks.uriLinkStream.listen(
        (uri) => _processDeepLink(uri),
      );
    } catch (e) {
      throw Exception('Error initializing Deep Links service: $e');
    }
  }

  /// Processa um Deep Link recebido
  void _processDeepLink(Uri uri) {
    if (uri.scheme == 'paintproapp' && uri.host == 'auth') {
      if (uri.pathSegments.contains('success')) {
        _deepLinkController.add(uri);
      } else if (uri.pathSegments.contains('error')) {
        _deepLinkController.add(uri);
      }
    }
  }

  /// Gera URL de callback para Deep Link
  String generateCallbackUrl() {
    return AppUrls.deepLinkSuccess;
  }

  /// Gera URL de erro para Deep Link
  String generateErrorUrl([String? error]) {
    final errorParam = error != null ? '?error=$error' : '';
    return AppUrls.deepLinkError + errorParam;
  }

  /// Dispara um Deep Link para o próprio app (para testes)
  void triggerDeepLink(String path) {
    final uri = Uri.parse('${AppUrls.deepLinkBaseUrl}/$path');
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
