import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:roomplan_flutter/roomplan_flutter.dart';

import '../config/app_colors.dart';
import '../config/dependency_injection.dart';
import '../viewmodel/roomplan/roomplan_viewmodel.dart';
import 'camera_photo_service.dart';

class CameraNavigationHandler {
  final BuildContext context;
  final CameraPhotoService photoService;
  final Map<String, dynamic>? projectData;
  final String? previousRoute;

  CameraNavigationHandler({
    required this.context,
    required this.photoService,
    this.projectData,
    this.previousRoute,
  });

  /// Handle back button press
  void onBackPressed() {
    if (photoService.photoCount > 0) {
      _showUnsavedPhotosDialog();
    } else {
      _navigateBack();
    }
  }

  /// Handle done button press
  void onDonePressed() {
    if (photoService.isDoneEnabled) {
      _navigateToNextScreen();
    }
  }

  /// Navigate back to previous screen
  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else if (previousRoute != null) {
      // If there's nothing to pop but we have a previous route, navigate to it
      context.go(previousRoute!);
    }
    // If there's nothing to pop and no previous route, stay on current screen
  }

  /// Navigate to next screen with photos
  void _navigateToNextScreen() {
    final photos = photoService.getAllPhotoPaths();

    // Se estamos vindo de uma zona, retornar as fotos para ela
    if (projectData != null && projectData!['zoneId'] != null) {
      // Retornar para a zona com as fotos atualizadas
      context.pop(photos);
    } else {
      // Start RoomPlan directly without intermediate screen
      _startRoomPlanDirectly(photos);
    }
  }

  /// Start RoomPlan directly without going through RoomPlanView
  Future<void> _startRoomPlanDirectly(List<String> photos) async {
    try {
      // Check if RoomPlan is supported
      final isSupported = await RoomPlanScanner.isSupported();
      if (!isSupported) {
        _showRoomPlanNotSupportedDialog();
        return;
      }

      // Create RoomPlan scanner
      final roomScanner = RoomPlanScanner();

      // Start scanning directly
      final result = await roomScanner.startScanning();

      if (result != null) {
        _processRoomPlanResult(result, photos);
      } else {
        context.pop(); // Go back to camera
      }
    } catch (e) {
      _showRoomPlanErrorDialog(e.toString());
    }
  }

  /// Process RoomPlan result and navigate to processing
  void _processRoomPlanResult(ScanResult result, List<String> photos) {
    try {
      // Get RoomPlanViewModel to process the result
      final roomPlanViewModel = getIt<RoomPlanViewModel>();

      final roomData = roomPlanViewModel.processScanResult(
        result,
        photos,
        projectData,
      );

      // Navigate directly to processing screen
      roomPlanViewModel.navigateToProcessing(
        context,
        roomData,
        photos,
        projectData,
      );
    } catch (e) {
      _showRoomPlanErrorDialog('Failed to process scan result: $e');
    }
  }

  /// Show dialog when RoomPlan is not supported
  void _showRoomPlanNotSupportedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RoomPlan Not Supported'),
        content: const Text(
          'RoomPlan is not supported on this device. Please use a device with LiDAR support.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop(); // Go back to camera
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when RoomPlan fails
  void _showRoomPlanErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RoomPlan Error'),
        content: Text('RoomPlan failed: $error'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.pop(); // Go back to camera
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when user tries to go back with unsaved photos
  void _showUnsavedPhotosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Exit',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.primaryDark,
          ),
        ),
        content: const Text(
          'Are you sure you want to go back? Any Photo will be lost.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray100,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              photoService.clearPhotos();
              _navigateBack();
            },
            child: const Text(
              'Yes, go back',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handle camera permission result
  void handlePermissionResult(bool granted) {
    if (!granted) {
      _navigateBack();
    }
  }
}
