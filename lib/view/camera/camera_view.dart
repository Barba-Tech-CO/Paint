import 'package:flutter/material.dart';

import '../../service/camera_dialog_service.dart';
import '../../service/camera_manager.dart';
import '../../service/camera_navigation_handler.dart';
import '../../service/camera_photo_service.dart';
import '../../widgets/camera/camera_app_bar_overlay.dart';
import '../../widgets/camera/camera_controls_bar.dart';
import '../../widgets/camera/camera_focus_overlay.dart';
import '../../widgets/camera/camera_preview_widget.dart';
import '../../widgets/camera/photo_thumbnails_row.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraManager _cameraManager;
  late CameraPhotoService _photoService;
  late CameraNavigationHandler _navigationHandler;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeCamera();
  }

  void _initializeServices() {
    _cameraManager = CameraManager();
    _photoService = CameraPhotoService();
    _navigationHandler = CameraNavigationHandler(
      context: context,
      photoService: _photoService,
    );
  }

  Future<void> _initializeCamera() async {
    final success = await _cameraManager.initialize();

    if (mounted) {
      if (!success) {
        await CameraDialogService.showCameraUnavailableDialog(
          context,
          onGoBack: () => _navigationHandler.onBackPressed(),
        );
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _toggleFlash() async {
    await _cameraManager.toggleFlash();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePhoto() async {
    final success = await _photoService.takePhoto(
      _cameraManager.cameraController,
    );

    if (mounted) {
      if (success) {
        setState(() {});
      } else if (!_photoService.canTakeMorePhotos) {
        await CameraDialogService.showPhotoLimitDialog(
          context,
          maxPhotos: 9,
          onContinue: () => _navigationHandler.onDonePressed(),
        );
      }
    }
  }

  @override
  void dispose() {
    _cameraManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          CameraPreviewWidget(
            cameraController: _cameraManager.cameraController,
            isInitialized: _cameraManager.isInitialized,
          ),

          // App Bar Overlay
          CameraAppBarOverlay(
            onBackPressed: () => _navigationHandler.onBackPressed(),
            onDonePressed: () => _navigationHandler.onDonePressed(),
            instructionText: _photoService.getInstructionText(),
            isDoneEnabled: _photoService.isDoneEnabled,
          ),

          // Focus Field Overlay
          const CameraFocusOverlay(),

          // Photo Thumbnails Row
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: PhotoThumbnailsRow(
              photos: _photoService.capturedPhotos,
            ),
          ),

          // Camera Controls
          CameraControlsBar(
            onTakePhoto: _takePhoto,
            onToggleFlash: _toggleFlash,
            flashMode: _cameraManager.flashMode,
            isShutterDisabled: !_photoService.canTakeMorePhotos,
          ),
        ],
      ),
    );
  }
}
