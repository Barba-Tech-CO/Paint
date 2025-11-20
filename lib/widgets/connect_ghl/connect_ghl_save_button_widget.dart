import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../viewmodel/connect_ghl/connect_ghl_viewmodel.dart';
import '../buttons/paint_pro_button.dart';
import 'connect_ghl_action_handler_widget.dart';

class ConnectGhlSaveButtonWidget extends StatelessWidget {
  final TextEditingController apiKeyController;
  final TextEditingController locationIdController;

  const ConnectGhlSaveButtonWidget({
    super.key,
    required this.apiKeyController,
    required this.locationIdController,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectGhlViewModel>(
      builder: (context, viewModel, child) {
        final buttonText = viewModel.hasExistingConfig
            ? 'Update Configuration'
            : 'Save Configuration';

        return SizedBox(
          width: double.infinity,
          child: PaintProButton(
            text: buttonText,
            onPressed: viewModel.isLoading
                ? null
                : () => ConnectGhlActionHandlerWidget.handleSave(
                    context,
                    viewModel,
                    apiKeyController,
                    locationIdController,
                  ),
            isLoading: viewModel.isLoading,
          ),
        );
      },
    );
  }
}
