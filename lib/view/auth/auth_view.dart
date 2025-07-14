import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../viewmodel/auth/auth_viewmodel.dart';
import '../widgets/overlay/loading_overlay.dart';
import '../widgets/webview_popup_screen.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  WebViewController? _webViewController;
  String? _authorizeUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAuthorizeUrl();
  }

  Future<void> _loadAuthorizeUrl() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      final url = await authViewModel.getAuthorizeUrl();
      setState(() {
        _authorizeUrl = url;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar URL de autorização: $e';
        _isLoading = false;
      });
    }
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    if (url.contains('code=')) {
      _handleCallback(url);
      return NavigationDecision.prevent;
    }
    if (url.contains('error=')) {
      _handleError(url);
      return NavigationDecision.prevent;
    }
    if (url.startsWith(
      'https://marketplace.gohighlevel.com/oauth/chooselocation',
    )) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => FractionallySizedBox(
          heightFactor: 0.95,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: WebViewPopupScreen(popupUrl: url),
          ),
        ),
      ).then((_) {
        _webViewController?.reload();
      });
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _handleCallback(String url) async {
    try {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      if (code != null) {
        final authViewModel = context.read<AuthViewModel>();
        setState(() {
          _isLoading = true;
        });
        final success = await authViewModel.processCallback(code);
        if (success) {
          context.go('/dashboard');
        } else {
          setState(() {
            _error = 'Erro na autorização. Tente novamente.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Erro no callback: $e';
        _isLoading = false;
      });
    }
  }

  void _handleError(String url) {
    final uri = Uri.parse(url);
    final error = uri.queryParameters['error'];
    final errorDescription = uri.queryParameters['error_description'];
    setState(() {
      _error = errorDescription ?? error ?? 'Erro na autorização';
    });
  }

  void _retry() {
    setState(() {
      _error = null;
      _isLoading = true;
    });
    _loadAuthorizeUrl();
  }

  Future<void> _clearWebViewData() async {
    final cookieManager = WebViewCookieManager();
    await cookieManager.clearCookies();
    await _webViewController?.clearCache();
    // Limpa localStorage e sessionStorage
    try {
      await _webViewController?.runJavaScript(
        'window.localStorage.clear(); window.sessionStorage.clear();',
      );
    } catch (_) {}
    // Tenta deletar todos os bancos IndexedDB conhecidos
    try {
      await _webViewController?.runJavaScript(
        'if(indexedDB.databases){indexedDB.databases().then(dbs => dbs.forEach(db => indexedDB.deleteDatabase(db.name)));}',
      );
    } catch (_) {}
    _webViewController?.reload();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cache, cookies e storage do WebView limpos!'),
      ),
    );
  }

  WebViewController _buildWebViewController(String url) {
    if (_webViewController != null) return _webViewController!;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _handleNavigation,
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    _webViewController = controller;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Autenticação'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpar Cookies e Cache',
            onPressed: _clearWebViewData,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_authorizeUrl != null && _error == null)
            WebViewWidget(
              controller: _buildWebViewController(_authorizeUrl!),
            ),
          if (_isLoading)
            const LoadingOverlay(
              isLoading: true,
              child: SizedBox.shrink(),
            ),
          if (_error != null) _buildErrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro de Autenticação',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
