import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../helpers/processing/processing_helper.dart';
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
    await ProcessingHelper.simulateProcessing();

    if (mounted) {
      _navigateToZones();
    }
  }

  void _navigateToZones() {
    // Cria dados da zona baseado no roomData ou dados padrão
    final zoneData = ProcessingHelper.createZoneDataFromRoomData(
      capturedPhotos: widget.capturedPhotos,
      roomData: widget.roomData,
      projectData: widget.projectData,
    );

    // Navega para a ZonesView com os dados da zona
    context.go('/zones', extra: zoneData);
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
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  strokeWidth: 3,
                ),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
