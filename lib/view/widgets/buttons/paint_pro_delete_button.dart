import 'package:flutter/material.dart';

import '../../../utils/logger/app_logger.dart';
import '../../../viewmodel/zones/zone_detail_viewmodel.dart';

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
        return IconButton(
          onPressed: viewModel.isDeleting
              ? null //
              : () => _handleDelete(context),
          icon: viewModel.isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(
                  Icons.delete_outline_rounded,
                ),
        );
      },
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final zone = viewModel.currentZone;
    if (zone == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Zone'),
        content: Text(
          'Are you sure you want to delete "${zone.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        // Use the new ViewModel delete method
        // The callbacks will handle UI coordination automatically
        await viewModel.deleteZone(zone.id);
      } catch (e) {
        // Log error silently - UI coordination still handled by callbacks
        _logger.error('Error deleting zone: $e');
      }
    }
  }
}
