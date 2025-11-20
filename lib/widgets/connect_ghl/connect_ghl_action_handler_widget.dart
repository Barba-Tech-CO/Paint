import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/snackbar_utils.dart';
import '../../viewmodel/connect_ghl/connect_ghl_viewmodel.dart';
import '../dialogs/delete_ghl_config_dialog.dart';

class ConnectGhlActionHandlerWidget extends StatelessWidget {
  final TextEditingController apiKeyController;
  final TextEditingController locationIdController;
  final Widget child;

  const ConnectGhlActionHandlerWidget({
    super.key,
    required this.apiKeyController,
    required this.locationIdController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectGhlViewModel>(
      builder: (context, viewModel, _) {
        // Listen to changes and show appropriate messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.hasError && viewModel.error != null) {
            SnackBarUtils.showError(
              context,
              message: viewModel.error!,
            );
            viewModel.clearError();
          }
        });

        return child;
      },
    );
  }

  static Future<void> handleSave(
    BuildContext context,
    ConnectGhlViewModel viewModel,
    TextEditingController apiKeyController,
    TextEditingController locationIdController,
  ) async {
    final wasExisting = viewModel.hasExistingConfig;

    await viewModel.saveGhlConfiguration(
      apiKey: apiKeyController.text,
      locationId: locationIdController.text,
    );

    if (context.mounted && !viewModel.hasError) {
      SnackBarUtils.showSuccess(
        context,
        message: wasExisting
            ? 'Configuration updated successfully!'
            : 'Configuration saved successfully!',
      );
    }
  }

  static Future<void> handleDelete(
    BuildContext context,
    ConnectGhlViewModel viewModel,
    TextEditingController apiKeyController,
    TextEditingController locationIdController,
  ) async {
    final confirmed = await DeleteGhlConfigDialog.show(context);

    if (confirmed && context.mounted) {
      await viewModel.deleteGhlConfiguration();

      if (context.mounted && !viewModel.hasError) {
        // Clear the text fields
        apiKeyController.clear();
        locationIdController.clear();

        SnackBarUtils.showSuccess(
          context,
          message: 'Configuration deleted successfully!',
        );
      }
    }
  }
}
