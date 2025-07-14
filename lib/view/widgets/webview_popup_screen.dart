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

  void _closeIfCallback(String url) async {
    final isCallback = url.startsWith(
      'https://paintpro.barbatech.company/oauth/callback',
    );
    final isGHLApp = url.startsWith('https://app.gohighlevel.com');
    if (!_alreadyClosed && (isCallback || isGHLApp)) {
      _alreadyClosed = true;
      if (isCallback) {
        log('[WebViewPopupScreen] Fechando modal por callback: $url');
      } else if (isGHLApp) {
        log(
          '[WebViewPopupScreen] Fechando modal por redirect para app.gohighlevel.com: $url',
        );
      }
      // Tenta logar o HTML da página final
      try {
        final html = await _popupController.runJavaScriptReturningResult(
          'document.documentElement.outerHTML',
        );
        log('HTML da página final:');
        log(html.toString());
      } catch (e) {
        log('Erro ao obter HTML da página final: $e');
      }
      context.pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _popupController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            log('[WebViewPopupScreen] Navegação para: ${request.url}');
            _closeIfCallback(request.url);
            return request.url.startsWith(
                  'https://paintpro.barbatech.company/oauth/callback',
                )
                ? NavigationDecision.prevent
                : NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            log('[WebViewPopupScreen] Início do carregamento: $url');
          },
          onPageFinished: (url) {
            log('[WebViewPopupScreen] Fim do carregamento: $url');
            _closeIfCallback(url);
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
