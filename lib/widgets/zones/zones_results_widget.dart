import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/dependency_injection.dart';
import '../../viewmodel/zones/zone_initializer_viewmodel.dart';
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
  late final ZoneInitializerViewModel _zoneInitializer;
  late Map<String, dynamic> _projectData;

  @override
  void initState() {
    super.initState();

    _listViewModel = getIt<ZonesListViewModel>();
    _summaryViewModel = getIt<ZonesSummaryViewModel>();
    _zoneInitializer = ZoneInitializerViewModel(listViewModel: _listViewModel);

    // Extract project data from initialZoneData
    _projectData = _extractProjectData();

    // Initialize ViewModels
    _summaryViewModel.initialize();

    // Setup listener to update summary when zones list changes
    _listViewModel.addListener(_updateSummary);

    // Process initial zone data
    _processInitialZoneData();
  }

  @override
  void didUpdateWidget(ZonesResultsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if initialZoneData changed
    if (widget.initialZoneData != oldWidget.initialZoneData) {
      _projectData = _extractProjectData();
      _processInitialZoneData();
    }
  }

  void _processInitialZoneData() {
    // Add initial zone data if available
    if (widget.initialZoneData != null) {
      // Try to add the zone immediately first
      _zoneInitializer.initializeZone(widget.initialZoneData!);

      // Also schedule for after build as backup to ensure the zone is processed
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

  Map<String, dynamic> _extractProjectData() {
    // Extract project data from initialZoneData
    if (widget.initialZoneData == null) {
      return {
        'projectName': '',
        'projectType': '',
        'clientId': '',
        'additionalNotes': '',
      };
    }
    return {
      'projectName': widget.initialZoneData!['projectName'],
      'projectType': widget.initialZoneData!['projectType'],
      'clientId': widget.initialZoneData!['clientId'],
      'additionalNotes': widget.initialZoneData!['additionalNotes'],
    };
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
                    projectData: _projectData,
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
