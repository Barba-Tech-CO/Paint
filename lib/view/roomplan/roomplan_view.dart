import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomplan_flutter/roomplan_flutter.dart';

import '../../config/dependency_injection.dart';
import '../../viewmodel/roomplan/roomplan_viewmodel.dart';

class RoomPlanView extends StatefulWidget {
  final List<String> capturedPhotos;
  final Map<String, dynamic>? projectData;

  const RoomPlanView({
    super.key,
    required this.capturedPhotos,
    this.projectData,
  });

  @override
  State<RoomPlanView> createState() => _RoomPlanViewState();
}

class _RoomPlanViewState extends State<RoomPlanView> {
  late RoomPlanViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<RoomPlanViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.checkSupport();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startRoomPlan() async {
    try {
      log('RoomPlanView: Starting RoomPlan...');
      await _viewModel.startScanning();

      // Wait for scan completion
      while (_viewModel.isScanning) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      final result = _viewModel.scanResult;
      if (result != null) {
        log('=== ROOMPLAN FINAL SCAN RESULT ===');
        log('RoomPlanView: Final scan completed');
        log('RoomPlanView: Walls: ${result.room.walls.length}');
        log('RoomPlanView: Doors: ${result.room.doors.length}');
        log('RoomPlanView: Windows: ${result.room.windows.length}');
        log('RoomPlanView: Objects: ${result.room.objects.length}');
        log('RoomPlanView: Openings: ${result.room.openings.length}');
        log('RoomPlanView: Floor: ${result.room.floor != null}');
        log('RoomPlanView: Ceiling: ${result.room.ceiling != null}');
        log('RoomPlanView: - LiDAR: ${result.metadata.hasLidar}');

        log('RoomPlanView: Confidence levels:');
        log('RoomPlanView: - Overall: ${result.confidence.overall}');
        log('=== END ROOMPLAN FINAL SCAN RESULT ===');

        final roomData = _viewModel.processScanResult(
          result,
          widget.capturedPhotos,
          widget.projectData,
        );
        _viewModel.navigateToProcessing(
          context,
          roomData,
          widget.capturedPhotos,
          widget.projectData,
        );
      } else {
        log('RoomPlanView: RoomPlan was cancelled');
      }
    } on RoomPlanPermissionsException {
      _viewModel.showErrorDialog(
        context,
        'Camera permission denied. Please grant camera access in Settings.',
      );
    } on ScanCancelledException {
      log('RoomPlanView: RoomPlan was cancelled by user');
    } catch (e) {
      log('RoomPlanView: Error during RoomPlan: $e');

      // Handle specific world tracking failure
      if (e.toString().contains('World tracking failure') ||
          e.toString().contains('native_error')) {
        _viewModel.showWorldTrackingErrorDialog(context, () {
          _viewModel.navigateToProcessingWithPhotosOnly(
            context,
            widget.capturedPhotos,
            widget.projectData,
          );
        });
      } else {
        _viewModel.showErrorDialog(context, 'RoomPlan failed: $e');
      }
    }
  }

  void _showIncompatibilityDialog() {
    _viewModel.showIncompatibilityDialog(context, () {
      _viewModel.navigateToProcessingWithPhotosOnly(
        context,
        widget.capturedPhotos,
        widget.projectData,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se não é suportado, mostra apenas o dialog de incompatibilidade
    if (!_viewModel.isSupported) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Se está escaneando, mostra interface mínima
    if (_viewModel.isScanning) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              SizedBox(height: 24),
              Text(
                'Starting Room Scan...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait while we prepare the scanning environment',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Interface principal do RoomPlan
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // RoomPlan Scanner Widget
          const Center(
            child: Text(
              'RoomPlan Scanner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Overlay com controles
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de voltar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () => context.pop(),
                  ),
                ),

                // Botão de incompatibilidade (para teste)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: _showIncompatibilityDialog,
                  ),
                ),
              ],
            ),
          ),

          // Botão de scan na parte inferior
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.black,
                    size: 32,
                  ),
                  iconSize: 32,
                  onPressed: _startRoomPlan,
                ),
              ),
            ),
          ),

          // Instruções na parte inferior
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 100,
            left: 16,
            right: 16,
            child: const Text(
              'Tap the camera button to start room scanning',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
