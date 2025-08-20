import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
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
    return WebViewWidget(
      controller: _buildWebViewController(widget.url),
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
                  
                  _logger.info('[AuthWebView] OAuth processing completed, navigating to home');
                  
                  // Navigate to home after successful processing
                  if (mounted && !_isDisposed) {
                    GoRouter.of(_widgetContext).go('/home');
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
