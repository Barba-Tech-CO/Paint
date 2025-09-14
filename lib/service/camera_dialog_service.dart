import 'package:flutter/material.dart';

class CameraDialogService {
  /// Show camera unavailable dialog
  static Future<void> showCameraUnavailableDialog(
    BuildContext context, {
    VoidCallback? onGoBack,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Camera Unavailable'),
        content: const Text(
          'Camera is not available on this device or simulator. Please use a physical device with a camera.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onGoBack?.call();
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  /// Show photo limit reached dialog
  static Future<void> showPhotoLimitDialog(
    BuildContext context, {
    required int maxPhotos,
    VoidCallback? onContinue,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photo Limit Reached'),
        content: Text(
          'You have reached the maximum of $maxPhotos photos. You can continue or remove some photos to take more.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onContinue?.call();
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog for clearing photos
  static Future<bool> showClearPhotosDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Photos'),
        content: const Text(
          'Are you sure you want to clear all captured photos? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show permission denied dialog
  static Future<void> showPermissionDeniedDialog(
    BuildContext context, {
    VoidCallback? onOpenSettings,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera Permission Required'),
        content: const Text(
          'This app needs camera permission to take photos. Please enable camera access in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (onOpenSettings != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOpenSettings();
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  /// Show error dialog with custom message
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}
