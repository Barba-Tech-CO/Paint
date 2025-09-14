import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/logger/logger_app_logger_impl.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import 'auth_content.dart';
import 'marketplace_popup_helper.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  static final AppLogger _logger = LoggerAppLoggerImpl();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        _handleSideEffects(context, viewModel);
        return Scaffold(
          appBar: PaintProAppBar(
            title: 'Authentication',
            backgroundColor: AppColors.primary,
            toolbarHeight: 80,
          ),
          body: const AuthContent(),
        );
      },
    );
  }

  void _handleSideEffects(BuildContext context, AuthViewModel viewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.shouldNavigateToDashboard) {
        try {
          context.go('/home');
        } catch (e) {
          _logger.error('[AuthView] Error navigating to dashboard: $e');
        }
      }

      if (viewModel.shouldShowPopup && viewModel.popupUrl != null) {
        MarketplacePopupHelper.show(context, viewModel.popupUrl!, viewModel);
      }
    });
  }
}
