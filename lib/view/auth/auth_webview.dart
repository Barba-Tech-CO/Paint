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
  AuthViewModel? _viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _widgetContext = context;
    if (_viewModel == null) {
      _viewModel = _widgetContext.read<AuthViewModel>();
    }
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
              if (mounted && !_isDisposed) {
                // Extract the authorization code from the URL
                final uri = Uri.parse(request.url);
                final code = uri.queryParameters['code'];

                if (code != null) {
                  // Process the callback with the authorization code
                  // Use a microtask to avoid blocking the navigation delegate
                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                    if (mounted && !_isDisposed) {
                      try {
                        await _viewModel!.processCallback(code);

                        // Wait for backend to process the authorization code
                        // and update the authentication state
                        await Future.delayed(
                          const Duration(milliseconds: 2000),
                        );

                        // Check auth status multiple times with retries
                        int retryCount = 0;
                        const maxRetries = 5;
                        bool authSuccessful = false;

                        while (retryCount < maxRetries &&
                            !authSuccessful &&
                            mounted &&
                            !_isDisposed) {
                          await _viewModel!.checkAuthStatusCommand.execute();

                          // Wait a bit for the state to update
                          await Future.delayed(
                            const Duration(milliseconds: 1000),
                          );

                          if (_viewModel!.shouldNavigateToDashboard) {
                            authSuccessful = true;
                            break;
                          }

                          retryCount++;
                          if (retryCount < maxRetries) {
                            await Future.delayed(
                              const Duration(milliseconds: 1000),
                            );
                          }
                        }

                        if (authSuccessful) {
                          // Navigate directly to home since auth is successful
                          try {
                            GoRouter.of(_widgetContext).go('/home');
                          } catch (e) {
                            LoggerService.error(
                              '[AuthWebView] Error navigating to home: $e',
                            );
                            // Fallback to closing webview
                            GoRouter.of(_widgetContext).pop();
                          }
                        } else {
                          // Close the webview and let AuthView handle navigation
                          GoRouter.of(_widgetContext).pop();
                        }
                      } catch (e) {
                        if (mounted && !_isDisposed) {
                          _viewModel!.handleError(
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
                      _viewModel!.handleError('No authorization code received');
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
                      _viewModel!,
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
