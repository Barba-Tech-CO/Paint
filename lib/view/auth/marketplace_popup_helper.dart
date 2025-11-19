import 'package:flutter/material.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../../widgets/webview_popup_screen.dart';

class MarketplacePopupHelper {
  static void show(BuildContext context, String url, AuthViewModel viewModel) {
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
          // If we get a valid URL back, update the authorize URL in the main webview
          viewModel.updateAuthorizeUrl(returnedUrl);
        }
      },
    );
  }
}
