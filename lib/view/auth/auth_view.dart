import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/dependency_injection.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/logger/logger_app_logger_impl.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../../viewmodel/auth/login_viewmodel.dart';
import 'login_screen.dart';
import 'marketplace_popup_helper.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  static final AppLogger _logger = LoggerAppLoggerImpl();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, child) {
        _handleSideEffects(context, viewModel);

        // Use LoginScreen instead of webview
        return ChangeNotifierProvider(
          create: (_) => getIt<LoginViewModel>(),
          child: Consumer<LoginViewModel>(
            builder: (context, loginViewModel, child) {
              _handleLoginSideEffects(context, loginViewModel);
              return const LoginScreen();
            },
          ),
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

  void _handleLoginSideEffects(BuildContext context, LoginViewModel loginViewModel) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Se o login foi bem-sucedido, navegar para o dashboard
      if (loginViewModel.loginSuccess) {
        try {
          context.go('/home');
        } catch (e) {
          _logger.error('[AuthView] Error navigating to home after login: $e');
        }
      }
    });
  }
}
