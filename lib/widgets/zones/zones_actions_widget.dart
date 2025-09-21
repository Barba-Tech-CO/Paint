import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../viewmodel/zones/zones_summary_viewmodel.dart';
import '../buttons/paint_pro_button.dart';
import '../dialogs/add_zone_dialog.dart';
import 'zones_summary_card.dart';

class ZonesActionsWidget extends StatelessWidget {
  final ZonesListViewModel listViewModel;
  final ZonesSummaryViewModel summaryViewModel;
  final Map<String, dynamic> projectData;

  const ZonesActionsWidget({
    super.key,
    required this.listViewModel,
    required this.summaryViewModel,
    required this.projectData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (summaryViewModel.summary != null)
          ZonesSummaryCard(
            avgDimensions: summaryViewModel.summary!.avgDimensions,
            totalArea: summaryViewModel.summary!.totalArea,
            totalPaintable: summaryViewModel.summary!.totalPaintable,
            onAdd: () => _showAddZoneDialog(context),
          ),
        const SizedBox(height: 32),
        PaintProButton(
          text: "Next",
          onPressed: () => context.push('/select-material', extra: projectData),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAddZoneDialog(BuildContext context) {
    AddZoneDialog.show(
      context,
      onAdd:
          ({
            required String title,
            required String zoneType,
          }) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                // Prepare project data for new zone using original project data
                final zoneProjectData = {
                  'zoneName': title,
                  'zoneType': zoneType,
                  'projectType': projectData['projectType'],
                  'clientId': projectData['clientId'],
                  'additionalNotes': projectData['additionalNotes'],
                  'projectName': projectData['projectName'],
                };

                // Navigate to camera with zone data
                context.push('/camera', extra: zoneProjectData);
              }
            });
          },
    );
  }
}
