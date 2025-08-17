import 'package:flutter/material.dart';

import '../../../../view/widgets/webview_popup_screen.dart';
import '../viewmodels/auth_viewmodel.dart';

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
          viewModel.updateAuthorizeUrl(returnedUrl);
        }
      },
    );
  }
}
