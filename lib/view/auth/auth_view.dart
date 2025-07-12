import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../../service/navigation_service.dart';
import '../widgets/overlay/loading_overlay.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  InAppWebViewController? _webViewController;
  String? _authorizeUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // A URL é carregada primeiro, e o WebView é construído depois no método build.
    _loadAuthorizeUrl();
  }

  Future<void> _loadAuthorizeUrl() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      final url = await authViewModel.getAuthorizeUrl();

      setState(() {
        _authorizeUrl = url;
        _isLoading = false; // O loading inicial é para obter a URL
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar URL de autorização: $e';
        _isLoading = false;
      });
    }
  }

  // O InAppWebView usa NavigationActionPolicy na versão 5.7.2+3
  Future<NavigationActionPolicy> _handleNavigation(Uri? uri) async {
    if (uri == null) return NavigationActionPolicy.CANCEL;

    final url = uri.toString();

    // Verifica se é o callback OAuth2
    if (url.contains('code=')) {
      _handleCallback(url);
      return NavigationActionPolicy.CANCEL;
    }

    // Verifica se é um erro
    if (url.contains('error=')) {
      _handleError(url);
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  Future<void> _handleCallback(String url) async {
    try {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];

      if (code != null) {
        final authViewModel = context.read<AuthViewModel>();
        final navigationService = context.read<NavigationService>();

        setState(() {
          _isLoading = true;
        });

        final success = await authViewModel.processCallback(code);

        if (success) {
          navigationService.navigateToDashboard(context);
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
            onPressed: () async {
              // Limpa todos os cookies do WebView
              await CookieManager.instance().deleteAllCookies();
              // Recarrega a página para refletir a limpeza
              _webViewController?.reload();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache e cookies do WebView limpos!'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Recarrega a página atual do WebView
              _webViewController?.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // WebView
          if (_authorizeUrl != null && _error == null)
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(_authorizeUrl!),
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  _isLoading = true;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  _isLoading = false;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return _handleNavigation(navigationAction.request.url);
              },
              onCreateWindow: (controller, createWindowAction) async {
                // "Tomamos as rédeas" da situação aqui
                // Carrega a nova janela no WebView principal
                _webViewController?.loadUrl(
                  urlRequest: createWindowAction.request,
                );
                // Retorna true para indicar que lidamos com a ação
                return true;
              },
            ),

          // Loading overlay
          if (_isLoading)
            const LoadingOverlay(
              isLoading: true,
              child: SizedBox.shrink(),
            ),

          // Error overlay
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
