import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for deleting GHL configuration
class DeleteGhlConfigDialog extends StatelessWidget {
  const DeleteGhlConfigDialog({super.key});

  /// Show the delete GHL configuration dialog
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const DeleteGhlConfigDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete Configuration',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete your Go High Level configuration?',
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.gray100,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(true),
          child: Text(
            'Yes, delete',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14.sp,
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
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
