import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../utils/command/command_builder.dart';
import '../../../../view/widgets/overlays/error_overlay.dart';
import '../../../../view/widgets/overlays/loading_overlay.dart';
import '../../domain/entities/auth_entity.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'auth_webview.dart';

class AuthContent extends StatelessWidget {
  const AuthContent({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    return CommandBuilder<AuthEntity>(
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
        if (viewModel.state.errorMessage != null) {
          return ErrorOverlay(
            error: viewModel.state.errorMessage!,
            onRetry: () {
              viewModel.checkAuthStatusCommand.execute();
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
