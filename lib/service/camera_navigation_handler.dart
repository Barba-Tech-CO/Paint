import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'camera_photo_service.dart';

class CameraNavigationHandler {
  final BuildContext context;
  final CameraPhotoService photoService;

  CameraNavigationHandler({
    required this.context,
    required this.photoService,
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
    } else {
      log('CameraNavigationHandler: Not enough photos taken to proceed');
    }
  }

  /// Navigate back to previous screen
  void _navigateBack() {
    context.pop();
  }

  /// Navigate to next screen with photos
  void _navigateToNextScreen() {
    // TODO: Pass captured photos to next screen
    final photos = photoService.getPhotoPaths();

    // For now, just pop back - you can modify this to navigate to specific route
    context.pop(photos);
  }

  /// Show dialog when user tries to go back with unsaved photos
  void _showUnsavedPhotosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Photos'),
        content: Text(
          'You have ${photoService.photoCount} unsaved photos. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              photoService.clearPhotos();
              _navigateBack();
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToNextScreen();
            },
            child: const Text('Save & Continue'),
          ),
        ],
      ),
    );
  }

  /// Handle camera permission result
  void handlePermissionResult(bool granted) {
    if (granted) {
      log('CameraNavigationHandler: Camera permission granted');
    } else {
      log('CameraNavigationHandler: Camera permission denied');
      _navigateBack();
    }
  }
}
