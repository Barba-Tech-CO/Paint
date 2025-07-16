import 'package:flutter/material.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:paintpro/view/widgets/overlays/error_overlay.dart';

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
              if (viewModel.state.authorizeUrl != null &&
                  viewModel.state.errorMessage == null)
                WebViewWidget(
                  controller: _buildWebViewController(
                    viewModel.state.authorizeUrl!,
                  ),
                ),
              if (viewModel.state.isLoading)
                const LoadingOverlay(
                  isLoading: true,
                  child: SizedBox.shrink(),
                ),
              if (viewModel.state.errorMessage != null)
                ErrorOverlay(
                  error: viewModel.state.errorMessage!,
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

  WebViewController _buildWebViewController(String url) {
    if (_webViewController != null) return _webViewController!;

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
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
