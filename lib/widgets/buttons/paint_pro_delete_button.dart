import 'package:flutter/material.dart';

import '../../utils/logger/app_logger.dart';
import '../../viewmodel/zones/zone_detail_viewmodel.dart';
import '../dialogs/delete_zone_dialog.dart';

class PaintProDeleteButton extends StatelessWidget {
  final ZoneDetailViewModel viewModel;
  final AppLogger _logger;

  const PaintProDeleteButton({
    super.key,
    required this.viewModel,
    required AppLogger logger,
  }) : _logger = logger;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        // Verificar se o widget ainda está montado e se a zona ainda existe
        if (!context.mounted || viewModel.currentZone == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: viewModel.isDeleting
              ? null
              : () => _handleDelete(context),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            child: viewModel.isDeleting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Image.asset(
                    'assets/icons/delete.png',
                    width: 24,
                    height: 24,
                  ),
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    if (!context.mounted) return;

    final zone = viewModel.currentZone;
    if (zone == null) return;

    final confirm = await DeleteZoneDialog.show(
      context,
      zoneName: zone.title,
    );

    if (confirm && context.mounted) {
      try {
        await viewModel.deleteZone(zone.id);
      } catch (e) {
        _logger.error('Error deleting zone: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting zone: $e')),
          );
        }
      }
    }
  }
}
