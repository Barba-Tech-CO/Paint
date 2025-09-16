import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Consolidated dialogs service for the entire application
class AppDialogs {
  // Private constructor to prevent instantiation
  AppDialogs._();

  /// Show exit zones confirmation dialog
  static Future<bool> showExitZonesDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit zones?'),
        content: const Text(
          'Are you sure you want to go back? Any unsaved measurements will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Yes, go back',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

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
              context.pop();
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
            onPressed: () {
              context.pop();
              onContinue?.call();
            },
            child: Text(
              'Continue',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
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
            onPressed: () => context.pop(true),
            child: Text(
              'Clear All',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
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
          if (onOpenSettings != null)
            TextButton(
              onPressed: () {
                context.pop();
                onOpenSettings();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(
                  color: AppColors.gray100,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
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
          if (onRetry != null)
            TextButton(
              onPressed: () {
                context.pop();
                onRetry();
              },
              child: Text(
                'Retry',
                style: TextStyle(
                  color: AppColors.gray100,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'OK',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show device incompatibility dialog
  static Future<void> showIncompatibilityDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          'Device Not Compatible',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room scanning is not available on this device.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Requirements:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• iOS 16.0 or later\n• Device with LiDAR sensor\n• iPhone 12 Pro or newer',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text(
              'You can still proceed with photo-based estimates.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Continue with Photos',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show delete quote dialog
  static Future<bool> showDeleteQuoteDialog(
    BuildContext context, {
    required String quoteName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Quote',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: '"$quoteName"',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(
                text:
                    '?\n\nThis action will permanently delete all related data, including extracted materials.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show rename quote dialog
  static Future<String?> showRenameQuoteDialog(
    BuildContext context, {
    required String initialName,
  }) async {
    final controller = TextEditingController(text: initialName);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Quote'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Quote Name'),
          autofocus: true,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => context.pop(controller.text.trim()),
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// Show rename zone dialog
  static Future<String?> showRenameZoneDialog(
    BuildContext context, {
    required String initialName,
  }) async {
    final controller = TextEditingController(text: initialName);
    final formKey = GlobalKey<FormState>();

    void handleSubmit() {
      if (formKey.currentState?.validate() == true) {
        final newName = controller.text.trim();
        context.pop(newName);
      }
    }

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Zone'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Zone Name',
              hintText: 'Enter new zone name',
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Zone name cannot be empty';
              }
              return null;
            },
            onFieldSubmitted: (_) => handleSubmit(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: handleSubmit,
            child: Text(
              'Rename',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// Show delete zone dialog
  static Future<bool> showDeleteZoneDialog(
    BuildContext context, {
    required String zoneName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Zone'),
        content: Text(
          'Are you sure you want to delete "$zoneName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.gray100,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show add zone dialog
  static Future<void> showAddZoneDialog(
    BuildContext context, {
    required Function({
      required String title,
      required String zoneType,
    })
    onAdd,
  }) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    String selectedZoneType = 'room';

    final List<String> zoneTypes = [
      'room',
      'bathroom',
      'kitchen',
      'bedroom',
      'living room',
      'dining room',
      'office',
      'basement',
      'attic',
      'garage',
      'other',
    ];

    void handleSubmit() {
      if (formKey.currentState?.validate() == true) {
        onAdd(
          title: titleController.text.trim(),
          zoneType: selectedZoneType,
        );
        context.pop();
      }
    }

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Zone'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Zone Name',
                    hintText: 'Enter zone name',
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Zone name is required';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => handleSubmit(),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedZoneType,
                  decoration: const InputDecoration(
                    labelText: 'Zone Type',
                  ),
                  items: zoneTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedZoneType = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: handleSubmit,
              child: Text(
                'Add Zone',
                style: TextStyle(
                  color: AppColors.gray100,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show rename zone dialog with ViewModel integration
  static Future<void> showRenameZoneDialogWithViewModel(
    BuildContext context, {
    required dynamic viewModel,
  }) async {
    final zone = viewModel.currentZone;
    if (zone == null) return;

    final newName = await showRenameZoneDialog(
      context,
      initialName: zone.title,
    );

    if (newName != null &&
        newName.isNotEmpty &&
        newName != zone.title &&
        context.mounted) {
      await viewModel.renameZone(zone.id, newName);
    }
  }

  /// Show delete photo confirmation dialog
  static Future<bool?> showDeletePhotoDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Delete Photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this photo?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(true),
              child: Text(
                'Yes, delete',
                style: TextStyle(
                  color: AppColors.gray100,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
