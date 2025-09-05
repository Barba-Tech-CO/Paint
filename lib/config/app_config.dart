import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  /// Alterne para `true` para usar o ambiente de produção.
  static const bool isProduction = false;

  /// URL de desenvolvimento principal (usada para iOS, Web, Desktop).
  static const String _devBaseUrl = 'http://localhost:8080/api';

  /// URL de produção. Substitua pela URL real do seu backend.
  static const String _prodBaseUrl = 'https://paintpro.barbatech.company/api';

  /// Retorna a URL base correta com base no ambiente e na plataforma.
  static String get baseUrl {
    if (isProduction) {
      if (kDebugMode) {
        log('[AppConfig] Using Production baseUrl: $_prodBaseUrl');
      }
      return _prodBaseUrl;
    } else {
      // Em desenvolvimento, verificamos se é Android para usar o IP especial.
      if (Platform.isAndroid) {
        final androidUrl = _devBaseUrl.replaceAll('localhost', '10.0.2.2');
        if (kDebugMode) {
          log('[AppConfig] Using Development Android baseUrl: $androidUrl');
        }
        // Converte 'localhost' para o IP do host da máquina no emulador Android.
        return androidUrl;
      }
      if (kDebugMode) {
        log('[AppConfig] Using Development baseUrl: $_devBaseUrl');
      }
      return _devBaseUrl;
    }
  }
}
