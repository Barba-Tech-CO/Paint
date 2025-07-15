import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPopupScreen extends StatefulWidget {
  final String popupUrl;
  const WebViewPopupScreen({super.key, required this.popupUrl});

  @override
  State<WebViewPopupScreen> createState() => _WebViewPopupScreenState();
}

class _WebViewPopupScreenState extends State<WebViewPopupScreen> {
  late final WebViewController _popupController;
  bool _alreadyClosed = false;

  // URLs que indicam que o login terminou e pode fechar o modal
  final List<String> _closeUrls = [
    'https://marketplace.gohighlevel.com/oauth/chooselocation',
    'https://marketplace.gohighlevel.com/',
    'https://app.gohighlevel.com/dashboard',
    'https://app.gohighlevel.com/home',
  ];

  void _closeIfLoginFinished(String url) {
    // Fecha o modal se o usuário saiu da tela de login
    final shouldClose = _closeUrls.any((closeUrl) => url.startsWith(closeUrl));
    if (!_alreadyClosed && shouldClose) {
      _alreadyClosed = true;
      log('[WebViewPopupScreen] Login finalizado, fechando modal: $url');
      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _popupController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            log('[WebViewPopupScreen] Navegação para: ${request.url}');
            _closeIfLoginFinished(request.url);
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            log('[WebViewPopupScreen] Início do carregamento: $url');
          },
          onPageFinished: (url) {
            log('[WebViewPopupScreen] Fim do carregamento: $url');
            _closeIfLoginFinished(url);
          },
          onWebResourceError: (error) {
            log(
              '[WebViewPopupScreen] Erro ao carregar recurso: ${error.description} (${error.errorCode})',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.popupUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completar Login'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: WebViewWidget(controller: _popupController),
    );
  }
}
