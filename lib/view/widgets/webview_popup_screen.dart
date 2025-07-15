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

  @override
  void initState() {
    super.initState();
    _popupController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            log('[WebViewPopupScreen] Início do carregamento: $url');
          },
          onPageFinished: (_) {},
          onWebResourceError: (error) {
            log(
              '[WebViewPopupScreen] Erro ao carregar recurso:  ${error.description} - (${error.errorCode})',
            );
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.popupUrl));
  }

  @override
  void dispose() {
    // Não há método dispose explícito no WebViewController atualmente,
    // mas se for adicionado no futuro, basta chamar aqui.
    // Exemplo: _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoHighLevel Login'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: WebViewWidget(controller: _popupController),
    );
  }
}
