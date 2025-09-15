import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/dependency_injection.dart';
import '../../helpers/zones/zone_initializer.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../viewmodel/zones/zones_summary_viewmodel.dart';
import 'zones_actions_widget.dart';
import 'zones_list_widget.dart';
import 'zones_loading_widget.dart';

class ZonesResultsWidget extends StatefulWidget {
  final Map<String, dynamic> results;
  final Map<String, dynamic>? initialZoneData;

  const ZonesResultsWidget({
    super.key,
    required this.results,
    this.initialZoneData,
  });

  @override
  State<ZonesResultsWidget> createState() => _ZonesResultsWidgetState();
}

class _ZonesResultsWidgetState extends State<ZonesResultsWidget> {
  late final ZonesListViewModel _listViewModel;
  late final ZonesSummaryViewModel _summaryViewModel;
  late final ZoneInitializer _zoneInitializer;

  @override
  void initState() {
    super.initState();
    _listViewModel = getIt<ZonesListViewModel>();
    _summaryViewModel = getIt<ZonesSummaryViewModel>();
    _zoneInitializer = ZoneInitializer(listViewModel: _listViewModel);

    // Initialize ViewModels
    _listViewModel.initialize();
    _summaryViewModel.initialize();

    // Setup listener to update summary when zones list changes
    _listViewModel.addListener(_updateSummary);

    // Add initial zone data if available
    if (widget.initialZoneData != null) {
      _zoneInitializer.initializeZoneAfterBuild(
        context,
        widget.initialZoneData!,
      );
    }
  }

  @override
  void dispose() {
    _listViewModel.removeListener(_updateSummary);
    super.dispose();
  }

  void _updateSummary() {
    _summaryViewModel.updateZonesList(_listViewModel.zones);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ZonesListViewModel>.value(value: _listViewModel),
        ChangeNotifierProvider<ZonesSummaryViewModel>.value(
          value: _summaryViewModel,
        ),
      ],
      child: Consumer2<ZonesListViewModel, ZonesSummaryViewModel>(
        builder: (context, listViewModel, summaryViewModel, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                ZonesLoadingWidget(listViewModel: listViewModel),
                if (!listViewModel.isLoading && !listViewModel.hasError) ...[
                  ZonesListWidget(listViewModel: listViewModel),
                  ZonesActionsWidget(
                    listViewModel: listViewModel,
                    summaryViewModel: summaryViewModel,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
