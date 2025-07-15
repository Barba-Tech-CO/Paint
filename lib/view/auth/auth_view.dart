import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/dependency_injection.dart';
import '../../service/deep_link_service.dart';
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
  late AuthViewModel _authViewModel;
  late DeepLinkService _deepLinkService;
  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _authViewModel = context.read<AuthViewModel>();
    _deepLinkService = getIt<DeepLinkService>();
    _initializeDeepLinkListener();

    // URL fixa do GHL
    const ghlAuthorizeUrl =
        'https://marketplace.gohighlevel.com/oauth/chooselocation?response_type=code&redirect_uri=https%3A%2F%2Fpaintpro.barbatech.company%2Fapi%2Foauth%2Fcallback&client_id=6845ab8de6772c0d5c8548d7-mbnty1f6&scope=contacts.write+associations.write+associations.readonly+oauth.readonly+oauth.write+invoices%2Festimate.write+invoices%2Festimate.readonly+invoices.readonly+associations%2Frelation.write+associations%2Frelation.readonly+contacts.readonly+invoices.write';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _authorizeUrl = ghlAuthorizeUrl;
        _isLoading = false;
      });
    });
  }

  void _initializeDeepLinkListener() {
    _deepLinkSubscription = _deepLinkService.deepLinkStream.listen(
      (uri) {
        if (uri.pathSegments.contains('success')) {
          // Autenticação bem-sucedida via Deep Link
          context.go('/dashboard');
        } else if (uri.pathSegments.contains('error')) {
          final error = uri.queryParameters['error'];
          setState(() {
            _error = error ?? 'Erro na autenticação';
          });
        }
      },
      onError: (error) {
        setState(() {
          _error = 'Erro ao processar callback de autenticação';
        });
      },
    );
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    log('[AuthView] Navegação para: $url');

    // 1. CONDIÇÃO DE SUCESSO FINAL (Prioridade máxima)
    if (url.contains('code=')) {
      log('[AuthView] Código de autorização detectado: $url');
      _handleCallback(url);
      return NavigationDecision.prevent;
    }

    if (url.contains('error=')) {
      log('[AuthView] Erro detectado: $url');
      _handleError(url);
      return NavigationDecision.prevent;
    }

    // 2. Se for a URL de nova aba do GHL, abre o modal simulando o popup
    if (url.startsWith('https://app.gohighlevel.com/?src=marketplace')) {
      log('[AuthView] Detected GHL new tab URL, abrindo modal: $url');
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
      );
      return NavigationDecision.prevent;
    }

    // 3. Permite navegação para todas as URLs do GoHighLevel
    if (url.startsWith('https://marketplace.gohighlevel.com') ||
        url.startsWith('https://app.gohighlevel.com') ||
        url.startsWith('https://highlevel-backend.firebaseapp.com')) {
      log('[AuthView] Navegação para GoHighLevel permitida: $url');
      return NavigationDecision.navigate;
    }

    return NavigationDecision.navigate;
  }

  Future<void> _handleCallback(String url) async {
    try {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      log('[AuthView] Processando callback - URL: $url');
      log('[AuthView] Código extraído: $code');

      if (code != null) {
        setState(() {
          _isLoading = true;
        });

        log('[AuthView] Chamando processCallback com código: $code');
        await _authViewModel.processCallback(code);

        // Verifica se a autenticação foi bem-sucedida
        log('[AuthView] Verificando se autenticação foi bem-sucedida...');
        await _authViewModel.checkAuthStatus();

        if (_authViewModel.isAuthenticated) {
          log('[AuthView] Autenticação bem-sucedida! Navegando para dashboard');
          context.go('/dashboard');
        } else {
          log(
            '[AuthView] Autenticação falhou. Erro: ${_authViewModel.errorMessage}',
          );
          setState(() {
            _error =
                _authViewModel.errorMessage ??
                'Erro na autorização. Tente novamente.';
            _isLoading = false;
          });
        }
      } else {
        log('[AuthView] Nenhum código encontrado na URL de callback');
        setState(() {
          _error = 'Código de autorização não encontrado na URL';
          _isLoading = false;
        });
      }
    } catch (e) {
      log('[AuthView] Erro no callback: $e');
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
    // Remover o método _loadAuthorizeUrl, pois não será mais usado.
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

  /// Mostra informações de debug
  Future<void> _showDebugInfo() async {
    try {
      final debugInfo = await _authViewModel.getDebugInfo();
      final status = _authViewModel.authStatus;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Debug Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('URL de Autorização: ${_authorizeUrl ?? "Não carregada"}'),
                const SizedBox(height: 8),
                Text('Is Loading: $_isLoading'),
                const SizedBox(height: 8),
                Text('Is Authenticated: ${_authViewModel.isAuthenticated}'),
                const SizedBox(height: 8),
                Text(
                  'Error Message: ${_authViewModel.errorMessage ?? "Nenhum"}',
                ),
                const SizedBox(height: 8),
                if (status != null) ...[
                  Text('Auth Status:'),
                  Text('  - Authenticated: ${status.authenticated}'),
                  Text('  - Needs Login: ${status.needsLogin}'),
                  Text('  - Location ID: ${status.locationId ?? "N/A"}'),
                  Text(
                    '  - Expires At: ${status.expiresAt?.toIso8601String() ?? "N/A"}',
                  ),
                ],
                const SizedBox(height: 8),
                if (debugInfo != null) ...[
                  Text('Debug Info:'),
                  Text('  - Total Tokens: ${debugInfo.totalTokens}'),
                  Text('  - Valid: ${debugInfo.valid}'),
                  Text('  - Expired: ${debugInfo.expired}'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao obter debug info: $e')),
      );
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  WebViewController _buildWebViewController(String url) {
    if (_webViewController != null) return _webViewController!;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
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
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Info',
            onPressed: _showDebugInfo,
          ),
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
          // Botão de verificação manual (apenas quando não há erro e não está carregando)
          if (_error == null && !_isLoading && _authorizeUrl != null)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () async {
                  try {
                    setState(() {
                      _isLoading = true;
                    });
                    await _authViewModel.checkAuthStatus();
                    if (_authViewModel.isAuthenticated) {
                      context.go('/dashboard');
                    } else {
                      setState(() {
                        _error =
                            _authViewModel.errorMessage ??
                            'Autenticação não foi completada. Tente novamente.';
                        _isLoading = false;
                      });
                    }
                  } catch (e) {
                    setState(() {
                      _error = 'Erro ao verificar autenticação: $e';
                      _isLoading = false;
                    });
                  }
                },
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ),
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
