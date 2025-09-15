import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../viewmodel/zones/zones_summary_viewmodel.dart';
import '../buttons/paint_pro_button.dart';
import '../dialogs/app_dialogs.dart';
import 'zones_summary_card.dart';

class ZonesActionsWidget extends StatelessWidget {
  final ZonesListViewModel listViewModel;
  final ZonesSummaryViewModel summaryViewModel;

  const ZonesActionsWidget({
    super.key,
    required this.listViewModel,
    required this.summaryViewModel,
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
          onPressed: () => context.push('/select-material'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _showAddZoneDialog(BuildContext context) {
    AppDialogs.showAddZoneDialog(
      context,
      onAdd:
          ({
            required String title,
            required String zoneType,
          }) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                // Navegar para a câmera/RoomPlan para capturar os dados
                context.go('/camera');
              }
            });
          },
    );
  }
}
