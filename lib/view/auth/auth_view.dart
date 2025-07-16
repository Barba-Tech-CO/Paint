import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/model/auth_model.dart';
import 'package:paintpro/utils/command/command_builder.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/view/widgets/overlays/error_overlay.dart';

import '../../viewmodel/auth/auth_viewmodel.dart';
import '../widgets/overlays/loading_overlay.dart';
import '../widgets/webview_popup_screen.dart';
import 'package:go_router/go_router.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  WebViewController? _webViewController;

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
          body: Column(
            children: [
              Expanded(
                child: CommandBuilder<AuthModel>(
                  command: viewModel.checkAuthStatusCommand,
                  onRunning: () => const LoadingOverlay(
                    isLoading: true,
                    child: SizedBox.shrink(),
                  ),
                  onError: (error) => ErrorOverlay(
                    error: error.toString(),
                    onRetry: () {
                      viewModel.checkAuthStatusCommand.execute();
                    },
                  ),
                  child: (result) {
                    if (viewModel.state.authorizeUrl != null) {
                      return WebViewWidget(
                        controller: _buildWebViewController(
                          viewModel.state.authorizeUrl!,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              CommandBuilder<void>(
                command: viewModel.processCallbackCommand,
                onRunning: () => const LoadingOverlay(
                  isLoading: true,
                  child: SizedBox.shrink(),
                ),
                onError: (error) => ErrorOverlay(
                  error: error.toString(),
                  onRetry: () {
                    // Não há retry direto, mas pode-se reexecutar se necessário
                  },
                ),
                child: (_) => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
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
            // Detecta URL de sucesso do backend
            if (request.url.contains('/auth/success')) {
              // Fechar a WebView ou navegar para próxima tela usando GoRouter
              GoRouter.of(context).pop();
              return NavigationDecision.prevent;
            }
            final viewModel = context.read<AuthViewModel>();
            final decision = await viewModel.handleWebViewNavigation(
              request.url,
            );

            if (decision == NavigationDecision.prevent) {
              // Verifica se deve mostrar popup do marketplace
              if (request.url.startsWith(
                'https://app.gohighlevel.com/?src=marketplace',
              )) {
                _showMarketplacePopup(request.url, viewModel);
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

  void _showMarketplacePopup(String url, AuthViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          child: WebViewPopupScreen(popupUrl: url),
        ),
      ),
    ).then(
      (returnedUrl) {
        if (returnedUrl is String && returnedUrl.isNotEmpty) {
          viewModel.updateAuthorizeUrl(returnedUrl);
          _webViewController = null;
        }
      },
    );
  }
}
