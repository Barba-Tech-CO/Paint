import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/connect_ghl/connect_ghl_viewmodel.dart';
import '../buttons/paint_pro_button.dart';
import 'connect_ghl_action_handler_widget.dart';

class ConnectGhlDeleteButtonWidget extends StatelessWidget {
  final TextEditingController apiKeyController;
  final TextEditingController locationIdController;

  const ConnectGhlDeleteButtonWidget({
    super.key,
    required this.apiKeyController,
    required this.locationIdController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectGhlViewModel>(
      builder: (context, viewModel, child) {
        if (!viewModel.hasExistingConfig) {
          return const SizedBox.shrink();
        }

        return SizedBox(
          width: double.infinity,
          child: PaintProButton(
            text: 'Delete Configuration',
            onPressed: viewModel.isLoading
                ? null
                : () => ConnectGhlActionHandlerWidget.handleDelete(
                    context,
                    viewModel,
                    apiKeyController,
                    locationIdController,
                  ),
            isLoading: viewModel.isLoading,
            backgroundColor: AppColors.error,
          ),
        );
      },
    );
  }
}
