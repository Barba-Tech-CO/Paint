import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/dialogs/exit_zones_dialog.dart';
import '../../widgets/loading/loading_widget.dart';
import '../../widgets/zones/zones_results_widget.dart';

class ZonesView extends StatefulWidget {
  final Map<String, dynamic>? initialZoneData;

  const ZonesView({
    super.key,
    this.initialZoneData,
  });

  @override
  State<ZonesView> createState() => _ZonesViewState();
}

class _ZonesViewState extends State<ZonesView> {
  @override
  void initState() {
    super.initState();
    // Initialize the viewModel when the view is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ZonesListViewModel>();
      viewModel.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await ExitZonesDialog.show(context);
        if (shouldLeave && context.mounted) {
          context.go('/new-project');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Consumer<ZonesListViewModel>(
          builder: (context, viewModel, child) {
            debugPrint(
              'ZonesView: Building with isLoading: ${viewModel.isLoading}',
            );
            return viewModel.isLoading
                ? const LoadingWidget()
                : Scaffold(
                    appBar: PaintProAppBar(title: 'Zones'),
                    body: ZonesResultsWidget(
                      results: const {},
                      initialZoneData: widget.initialZoneData,
                    ),
                  );
          },
        ),
      ),
    );
  }
}
