import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../service/services.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../widgets/appbars/paint_pro_app_bar.dart';
import 'auth_content.dart';
import 'marketplace_popup_helper.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        _handleSideEffects(context, viewModel);
        return Scaffold(
          appBar: PaintProAppBar(
            title: 'Authentication',
            backgroundColor: AppColors.primary,
            toolbarHeight: 60,
          ),
          body: const AuthContent(),
        );
      },
    );
  }

  void _handleSideEffects(BuildContext context, AuthViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.shouldNavigateToDashboard) {
        context.go('/home');
      }

      if (viewModel.shouldShowPopup && viewModel.popupUrl != null) {
        LoggerService.info('[AuthView] Showing marketplace popup');
        MarketplacePopupHelper.show(context, viewModel.popupUrl!, viewModel);
      }
    });
  }
}
