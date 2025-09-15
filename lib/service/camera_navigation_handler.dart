import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_colors.dart';
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
    final photos = photoService.getPhotoPaths();

    // Navigate to RoomPlan view with captured photos
    context.push(
      '/roomplan',
      extra: photos,
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
    if (granted) {
      log('CameraNavigationHandler: Camera permission granted');
    } else {
      log('CameraNavigationHandler: Camera permission denied');
      _navigateBack();
    }
  }
}
