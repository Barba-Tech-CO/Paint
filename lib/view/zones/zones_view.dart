import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
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
    return Consumer<ZonesListViewModel>(
      builder: (context, viewModel, child) {
        return viewModel.isLoading
            ? Scaffold(
                backgroundColor: AppColors.background,
                body: const LoadingWidget(),
              )
            : Scaffold(
                backgroundColor: AppColors.background,
                appBar: PaintProAppBar(title: 'Zones'),
                body: ZonesResultsWidget(
                  results: const {},
                  initialZoneData: widget.initialZoneData,
                ),
              );
      },
    );
  }
}
