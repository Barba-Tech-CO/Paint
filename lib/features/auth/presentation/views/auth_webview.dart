import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../viewmodels/auth_viewmodel.dart';
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
            if (request.url.contains('/auth/success')) {
              if (mounted) {
                GoRouter.of(_widgetContext).pop();
              }
              return NavigationDecision.prevent;
            }
            final viewModel = _widgetContext.read<AuthViewModel>();
            final decision = await viewModel.handleWebViewNavigation(
              request.url,
            );
            if (decision == NavigationDecision.prevent) {
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
              }
              return NavigationDecision.prevent;
            }
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
