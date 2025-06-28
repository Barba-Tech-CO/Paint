import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../../service/navigation_service.dart';
import '../widgets/loading_overlay.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  late WebViewController _webViewController;
  String? _authorizeUrl;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadAuthorizeUrl();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            return _handleNavigation(request.url);
          },
        ),
      );
  }

  Future<void> _loadAuthorizeUrl() async {
    try {
      final authViewModel = context.read<AuthViewModel>();
      final url = await authViewModel.getAuthorizeUrl();

      setState(() {
        _authorizeUrl = url;
      });
      _webViewController.loadRequest(Uri.parse(url));
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar URL de autorização: $e';
      });
    }
  }

  NavigationDecision _handleNavigation(String url) {
    // Verifica se é o callback OAuth2
    if (url.contains('code=')) {
      _handleCallback(url);
      return NavigationDecision.prevent;
    }

    // Verifica se é um erro
    if (url.contains('error=')) {
      _handleError(url);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _handleCallback(String url) async {
    try {
      // Extrai o código de autorização da URL
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];

      if (code != null) {
        final authViewModel = context.read<AuthViewModel>();
        final navigationService = context.read<NavigationService>();

        final success = await authViewModel.processCallback(code);

        if (success) {
          navigationService.navigateToDashboard(context);
        } else {
          setState(() {
            _error = 'Erro na autorização. Tente novamente.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Erro no callback: $e';
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
    });
    _loadAuthorizeUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autenticação'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // WebView
          if (_authorizeUrl != null && _error == null)
            WebViewWidget(controller: _webViewController),

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
