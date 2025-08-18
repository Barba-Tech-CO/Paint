import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../service/logger_service.dart';
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

  @override
  Widget build(BuildContext context) {
    _widgetContext = context;
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
            final viewModel = _widgetContext.read<AuthViewModel>();

            // Check if this is the OAuth callback URL
            if (request.url.contains(
              'paintpro.barbatech.company/api/oauth/callback',
            )) {
              if (mounted) {
                // Extract the authorization code from the URL
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];

                if (code != null) {
                  LoggerService.info('[AuthWebView] Authorization code received: $code');
                  // Process the callback with the authorization code
                  await viewModel.processCallback(code);
                  // Wait a bit for the state to update, then check auth status
                  await Future.delayed(const Duration(milliseconds: 500));
                  // Force a refresh of auth status
                  await viewModel.checkAuthStatusCommand.execute();
                  // Close the webview after processing
                  GoRouter.of(_widgetContext).pop();
                } else {
                  LoggerService.info(
                    '[AuthWebView] No authorization code in URL: $request.url',
                  );
                  // Handle error case
                  viewModel.handleError('No authorization code received');
                  GoRouter.of(_widgetContext).pop();
                }
              }
              return NavigationDecision.prevent;
            }

            // Handle marketplace popup
            if (request.url.startsWith(
              'https://app.gohighlevel.com/?src=marketplace',
            )) {
              if (mounted) {
                MarketplacePopupHelper.show(
                  _widgetContext,
                  request.url,
                  viewModel,
                );
              }
              return NavigationDecision.prevent;
            }

            // Let other navigation proceed normally
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            context.read<AuthViewModel>().setLoading(true);
          },
          onPageFinished: (url) {
            context.read<AuthViewModel>().setLoading(false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    _webViewController = controller;
    return controller;
  }
}
