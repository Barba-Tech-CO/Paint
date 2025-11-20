import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for deleting photos
class DeletePhotoDialog extends StatelessWidget {
  const DeletePhotoDialog({super.key});

  /// Show the delete photo dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => const DeletePhotoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete Photo',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this photo?',
        style: TextStyle(
          fontSize: 16.sp,
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
