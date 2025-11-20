import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for deleting zones
class DeleteZoneDialog extends StatelessWidget {
  final String zoneName;

  const DeleteZoneDialog({
    super.key,
    required this.zoneName,
  });

  /// Show the delete zone dialog
  static Future<bool> show(
    BuildContext context, {
    required String zoneName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteZoneDialog(zoneName: zoneName),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
              fontSize: 16.sp,
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
              fontSize: 16.sp,
            ),
          ),
        ),
      ],
    );
  }
}
