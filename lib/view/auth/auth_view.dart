import 'dart:async';

import 'package:flutter/material.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:paintpro/view/widgets/overlays/error_overlay.dart';

import '../../config/dependency_injection.dart';
import '../../service/deep_link_service.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../widgets/overlays/loading_overlay.dart';
import '../widgets/webview_popup_screen.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  WebViewController? _webViewController;
  String? _authorizeUrl;
  late AuthViewModel _authViewModel;
  late DeepLinkService _deepLinkService;
  StreamSubscription? _deepLinkSubscription;

  @override
  void initState() {
    super.initState();
    _authViewModel = context.read<AuthViewModel>();
    _deepLinkService = getIt<DeepLinkService>();
    _initializeDeepLinkListener();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final url = await _authViewModel.getAuthorizeUrl();
      setState(() {
        _authorizeUrl = url;
      });
    });
  }

  void _initializeDeepLinkListener() {
    _deepLinkSubscription = _deepLinkService.deepLinkStream.listen(
      (uri) {
        if (uri.pathSegments.contains('success')) {
          _authViewModel.checkAuthStatus();
        } else if (uri.pathSegments.contains('error')) {
          final error = uri.queryParameters['error'];
          _authViewModel.handleError(error ?? 'Erro na autenticação');
        }
      },
      onError: (error) {
        _authViewModel.handleError(
          'Erro ao processar callback de autenticação',
        );
      },
    );
  }

  NavigationDecision _handleNavigation(NavigationRequest request) {
    final url = request.url;
    if (url.contains('code=')) {
      final uri = Uri.parse(url);
      final code = uri.queryParameters['code'];
      if (code != null) {
        _authViewModel.processCallback(code);
      } else {
        _authViewModel.handleError(
          'Código de autorização não encontrado na URL',
        );
      }
      return NavigationDecision.prevent;
    }
    if (url.contains('error=')) {
      final uri = Uri.parse(url);
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];
      _authViewModel.handleError(
        errorDescription ?? error ?? 'Erro na autorização',
      );
      return NavigationDecision.prevent;
    }
    if (url.startsWith('https://app.gohighlevel.com/?src=marketplace')) {
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
      ).then((returnedUrl) {
        if (returnedUrl is String && returnedUrl.isNotEmpty) {
          setState(() {
            _authorizeUrl = returnedUrl;
            _webViewController = null;
          });
        }
      });
      return NavigationDecision.prevent;
    }
    if (url.startsWith('https://marketplace.gohighlevel.com') ||
        url.startsWith('https://app.gohighlevel.com') ||
        url.startsWith('https://highlevel-backend.firebaseapp.com')) {
      return NavigationDecision.navigate;
    }
    return NavigationDecision.navigate;
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
            _authViewModel.setLoading(true);
          },
          onPageFinished: (url) {
            _authViewModel.setLoading(false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    _webViewController = controller;
    return controller;
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: PaintProAppBar(
            title: 'Authentication',
            backgroundColor: AppColors.primary,
            toolbarHeight: 60,
          ),
          body: Stack(
            children: [
              if (_authorizeUrl != null && viewModel.errorMessage == null)
                WebViewWidget(
                  controller: _buildWebViewController(_authorizeUrl!),
                ),
              if (viewModel.isLoading)
                const LoadingOverlay(
                  isLoading: true,
                  child: SizedBox.shrink(),
                ),
              if (viewModel.errorMessage != null)
                ErrorOverlay(
                  error: viewModel.errorMessage!,
                  onRetry: () {
                    viewModel.clearError();
                    viewModel.setLoading(false);
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
