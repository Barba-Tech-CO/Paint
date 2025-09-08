import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../model/models.dart';
import '../../utils/command/command_builder.dart';
import '../../viewmodel/auth/auth_viewmodel.dart';
import '../widgets/overlays/error_overlay.dart';
import '../widgets/overlays/loading_overlay.dart';
import 'auth_webview.dart';

class AuthContent extends StatelessWidget {
  const AuthContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    return CommandBuilder<AuthModel>(
      command: viewModel.checkAuthStatusCommand,
      onRunning: () => const LoadingOverlay(
        isLoading: true,
        child: SizedBox.shrink(),
      ),
      onError: (error) => ErrorOverlay(
        error: error.toString(),
        onRetry: () {
          viewModel.retryAuthentication();
        },
      ),
      child: (result) {
        if (viewModel.state.errorMessage != null) {
          return ErrorOverlay(
            error: viewModel.state.errorMessage!,
            onRetry: () {
              viewModel.retryAuthentication();
            },
          );
        }
        if (viewModel.state.authorizeUrl != null) {
          return AuthWebView(url: viewModel.state.authorizeUrl!);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
