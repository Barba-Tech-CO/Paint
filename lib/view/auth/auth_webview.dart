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
  bool _isDisposed = false;

  @override
  Widget build(BuildContext context) {
    _widgetContext = context;
    return WebViewWidget(
      controller: _buildWebViewController(widget.url),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
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
              if (mounted && !_isDisposed) {
                // Extract the authorization code from the URL
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];

                if (code != null) {
                  LoggerService.info(
                    '[AuthWebView] Authorization code received: $code',
                  );

                  // Process the callback with the authorization code
                  // Use a microtask to avoid blocking the navigation delegate
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (mounted && !_isDisposed) {
                      try {
                        LoggerService.info(
                          '[AuthWebView] Processing callback...',
                        );
                        await viewModel.processCallback(code);

                        LoggerService.info(
                          '[AuthWebView] Callback processed, checking auth status...',
                        );
                        // Wait a bit for the state to update, then check auth status
                        await Future.delayed(const Duration(milliseconds: 500));

                        // Force a refresh of auth status
                        await viewModel.checkAuthStatusCommand.execute();

                        LoggerService.info(
                          '[AuthWebView] Auth status updated, closing webview...',
                        );
                        // Close the webview after processing
                        if (mounted && !_isDisposed) {
                          LoggerService.info(
                            '[AuthWebView] Triggering force navigation to home',
                          );
                          // Use the view model to force navigation
                          viewModel.forceNavigateToHome();

                          // Also try to close the webview directly
                          try {
                            LoggerService.info(
                              '[AuthWebView] Closing webview...',
                            );
                            GoRouter.of(_widgetContext).pop();
                          } catch (e) {
                            LoggerService.error(
                              '[AuthWebView] Error closing webview: $e',
                            );
                            // If pop fails, navigate to home
                            try {
                              GoRouter.of(_widgetContext).go('/home');
                            } catch (e2) {
                              LoggerService.error(
                                '[AuthWebView] Error navigating to home: $e2',
                              );
                            }
                          }
                        }
                      } catch (e) {
                        LoggerService.error(
                          '[AuthWebView] Error processing callback: $e',
                        );
                        if (mounted && !_isDisposed) {
                          viewModel.handleError(
                            'Error processing callback: $e',
                          );
                          // Try to close webview even on error
                          try {
                            GoRouter.of(_widgetContext).pop();
                          } catch (e) {
                            LoggerService.error(
                              '[AuthWebView] Error closing webview: $e',
                            );
                            GoRouter.of(_widgetContext).go('/home');
                          }
                        }
                      }
                    }
                  });
                } else {
                  LoggerService.info(
                    '[AuthWebView] No authorization code in URL: $request.url',
                  );
                  // Handle error case
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_isDisposed) {
                      viewModel.handleError('No authorization code received');
                      GoRouter.of(_widgetContext).pop();
                    }
                  });
                }
              }
              return NavigationDecision.prevent;
            }

            // Handle marketplace popup
            if (request.url.startsWith(
              'https://app.gohighlevel.com/?src=marketplace',
            )) {
              if (mounted && !_isDisposed) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isDisposed) {
                    MarketplacePopupHelper.show(
                      _widgetContext,
                      request.url,
                      viewModel,
                    );
                  }
                });
              }
              return NavigationDecision.prevent;
            }

            // Let other navigation proceed normally
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            if (mounted && !_isDisposed) {
              context.read<AuthViewModel>().setLoading(true);
            }
          },
          onPageFinished: (url) {
            if (mounted && !_isDisposed) {
              context.read<AuthViewModel>().setLoading(false);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    _webViewController = controller;
    return controller;
  }
}
