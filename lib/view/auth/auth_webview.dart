import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../service/auth_webview_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/logger/logger_app_logger_impl.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import 'auth_error_state.dart';

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
  late final AuthWebViewService _webViewService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _widgetContext = context;
    _viewModel ??= _widgetContext.read<AuthViewModel>();
    _webViewService = AuthWebViewService(_logger);
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
          return AuthErrorState(authViewModel: authViewModel);
        }

        return WebViewWidget(
          controller: _buildWebViewController(widget.url),
        );
      },
    );
  }

  WebViewController _buildWebViewController(String url) {
    if (_webViewController != null) return _webViewController!;

    if (_viewModel == null) {
      throw Exception('AuthViewModel not initialized');
    }

    final controller = _webViewService.createController(
      url: url,
      authViewModel: _viewModel!,
      context: _widgetContext,
      onMountedCheck: () => mounted,
      isDisposedCheck: () => _isDisposed,
    );

    _webViewController = controller;
    return controller;
  }
}
