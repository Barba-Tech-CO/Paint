import 'package:flutter/material.dart';

import '../../viewmodel/camera/camera_viewmodel.dart';
import '../../widgets/camera/camera_app_bar_overlay.dart';
import '../../widgets/camera/camera_controls_bar.dart';
import '../../widgets/camera/camera_focus_overlay.dart';
import '../../widgets/camera/camera_preview_widget.dart';
import '../../widgets/camera/photo_thumbnails_row.dart';

class CameraView extends StatefulWidget {
  final Map<String, dynamic>? projectData;

  const CameraView({super.key, this.projectData});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  late CameraViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CameraViewModel(projectData: widget.projectData);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await _viewModel.initialize();
    _viewModel.setNavigationContext(context);

    if (mounted) {
      if (_viewModel.needsCameraUnavailableDialog) {
        await _viewModel.showCameraUnavailableDialog(context);
      }
      setState(() {});
    }
  }

  Future<void> _toggleFlash() async {
    await _viewModel.toggleFlash();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _takePhoto() async {
    final success = await _viewModel.takePhoto();

    if (mounted) {
      if (!success && _viewModel.needsPhotoLimitDialog) {
        await _viewModel.showPhotoLimitDialog(context);
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
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
            cameraController: _viewModel.cameraManager.cameraController,
            isInitialized: _viewModel.isInitialized,
          ),

          // App Bar Overlay
          CameraAppBarOverlay(
            onBackPressed: () => _viewModel.onBackPressed(),
            onDonePressed: () => _viewModel.onDonePressed(),
            instructionText: _viewModel.photoService.getInstructionText(),
            isDoneEnabled: _viewModel.photoService.isDoneEnabled,
          ),

          // Focus Field Overlay
          const CameraFocusOverlay(),

          // Photo Thumbnails Row
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: PhotoThumbnailsRow(
              photos: _viewModel.photoService.allPhotos,
            ),
          ),

          // Camera Controls
          CameraControlsBar(
            onTakePhoto: _takePhoto,
            onToggleFlash: _toggleFlash,
            flashMode: _viewModel.cameraManager.flashMode,
            isShutterDisabled: !_viewModel.photoService.canTakeMorePhotos,
          ),
        ],
      ),
    );
  }
}
