import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/dialogs/app_dialogs.dart';
import '../../widgets/loading/loading_widget.dart';
import '../../widgets/zones/zones_results_widget.dart';

class ZonesView extends StatelessWidget {
  final Map<String, dynamic>? initialZoneData;

  const ZonesView({
    super.key,
    this.initialZoneData,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await AppDialogs.showExitZonesDialog(context);
        if (shouldLeave && context.mounted) {
          context.go('/new-project');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<ZonesListViewModel>(
          builder: (context, viewModel, child) {
            // Inicializa o ViewModel apenas uma vez
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (viewModel.state == ZonesListState.initial) {
                viewModel.initialize();
              }
            });
            return viewModel.isLoading
                ? const LoadingWidget()
                : Scaffold(
                    appBar: PaintProAppBar(title: 'Zones'),
                    body: ZonesResultsWidget(
                      results: const {},
                      initialZoneData: initialZoneData,
                    ),
                  );
          },
        ),
      ),
    );
  }
}
