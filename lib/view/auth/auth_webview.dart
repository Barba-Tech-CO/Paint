import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../model/auth_state.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/logger/logger_app_logger_impl.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import 'marketplace_popup_helper.dart';

class AuthWebView extends StatefulWidget {
  final String url;
  const AuthWebView({super.key, required this.url});

  @override
  State<AuthWebView> createState() => _AuthWebViewState();
}

class _AuthWebViewState extends State<AuthWebView> {
  WebViewController? _webViewController;
  late BuildContext _widgetContext;
  bool _isDisposed = false;
  AuthViewModel? _viewModel;
  static final AppLogger _logger = LoggerAppLoggerImpl();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _widgetContext = context;
    _viewModel ??= _widgetContext.read<AuthViewModel>();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        // Check if there's an error state
        if (authViewModel.state.isError) {
          return _buildErrorState(authViewModel);
        }
        
        return WebViewWidget(
          controller: _buildWebViewController(widget.url),
        );
      },
    );
  }

  Widget _buildErrorState(AuthViewModel authViewModel) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                authViewModel.state.errorMessage ?? 'Unable to complete authentication',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (authViewModel.state.canRetry) ...[
                ElevatedButton(
                  onPressed: () async {
                    await authViewModel.retryAuthentication();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  WebViewController _buildWebViewController(String url) {
    if (_webViewController != null) return _webViewController!;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            if (_viewModel == null) return NavigationDecision.navigate;

            // Check if this is the OAuth callback URL
            if (request.url.contains(
              'paintpro.barbatech.company/api/auth/callback',
            )) {
              _logger.info('[AuthWebView] OAuth callback detected: ${request.url}');
              
              // Extract the code and process it through the proper OAuth flow
              final uri = Uri.parse(request.url);
              final code = uri.queryParameters['code'];
              
              if (code != null) {
                _logger.info('[AuthWebView] Processing OAuth code through auth service: $code');
                
                try {
                  // Use the proper OAuth flow through AuthViewModel
                  await _viewModel!.processCallback(code);
                  
                  // Only navigate if processing was successful and state is authenticated
                  if (mounted && !_isDisposed && _viewModel!.state.state == AuthState.authenticated) {
                    _logger.info('[AuthWebView] OAuth processing completed successfully, navigating to home');
                    GoRouter.of(_widgetContext).go('/home');
                  } else if (_viewModel!.state.isError) {
                    _logger.warning('[AuthWebView] OAuth processing failed, staying on auth page to show error');
                    // Error state will be handled by the Consumer widget in build method
                  }
                  
                } catch (e) {
                  _logger.error('[AuthWebView] Error processing OAuth callback: $e');
                  if (_viewModel != null) {
                    _viewModel!.handleError('Error completing authentication: $e');
                  }
                }
              } else {
                _logger.error('[AuthWebView] No code found in callback URL');
              }
              
              // Prevent navigation to avoid webview SSL issues
              return NavigationDecision.prevent;
            }

            // Handle marketplace popup
            if (request.url.startsWith(
              'https://app.gohighlevel.com/?src=marketplace',
            )) {
              if (mounted && !_isDisposed && _viewModel != null) {
                MarketplacePopupHelper.show(
                  _widgetContext,
                  request.url,
                  _viewModel!,
                );
              }
              return NavigationDecision.prevent;
            }

            // Let other navigation proceed normally
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (mounted && !_isDisposed && _viewModel != null) {
              _viewModel!.setLoading(true);
            }
          },
          onPageFinished: (url) {
            if (mounted && !_isDisposed && _viewModel != null) {
              _viewModel!.setLoading(false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    _webViewController = controller;
    return controller;
  }
}
