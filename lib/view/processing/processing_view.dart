import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/zones/zones_list_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';

class ProcessingView extends StatefulWidget {
  final List<String> capturedPhotos;
  final Map<String, dynamic>? roomData;
  final Map<String, dynamic>? projectData;

  const ProcessingView({
    super.key,
    required this.capturedPhotos,
    this.roomData,
    this.projectData,
  });

  @override
  State<ProcessingView> createState() => _ProcessingViewState();
}

class _ProcessingViewState extends State<ProcessingView> {
  @override
  void initState() {
    super.initState();
    _startProcessing();
  }

  Future<void> _startProcessing() async {
    try {
      // Log para debug
      log('ProcessingView: Starting processing...');

      await ZonesListViewModel.simulateProcessing();

      log(
        'ProcessingView: Processing completed, navigating to zones...',
      );

      if (mounted) {
        _navigateToZones();
      } else {
        log('ProcessingView: Widget not mounted, skipping navigation');
      }
    } catch (e) {
      log('ProcessingView: Error during processing: $e');
      if (mounted) {
        _navigateToZones(); // Continue even if there's an error
      }
    }
  }

  void _navigateToZones() {
    try {
      log('ProcessingView: Creating zone data...');

      // Cria dados da zona baseado no roomData - dados sempre disponíveis
      final zoneData = ZonesListViewModel.createZoneDataFromRoomData(
        capturedPhotos: widget.capturedPhotos,
        roomData: widget.roomData ?? {},
        projectData: widget.projectData ?? {},
      );

      log('ProcessingView: Zone data created, navigating to zones...');
      log('ProcessingView: Zone data keys: ${zoneData.keys.toList()}');

      // Navega para a ZonesView com os dados da zona
      context.go('/zones', extra: zoneData);

      log('ProcessingView: Navigation to zones completed');
    } catch (e) {
      log('ProcessingView: Error navigating to zones: $e');
      // Fallback: try to navigate without extra data
      try {
        context.go('/zones');
      } catch (e2) {
        log('ProcessingView: Fallback navigation also failed: $e2');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaintProAppBar(
        title: 'Processing...',
        backgroundColor: AppColors.primary,
        textColor: AppColors.textOnPrimary,
        toolbarHeight: 80,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Loading Animation
            Column(
              children: [
                Text(
                  'Processing Photos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Calculating measurements...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary80,
                  ),
                ),
                const SizedBox(height: 32),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  strokeWidth: 3,
                  constraints: BoxConstraints(
                    maxWidth: 100,
                    maxHeight: 100,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
