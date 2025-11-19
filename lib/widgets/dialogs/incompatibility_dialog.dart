import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for device incompatibility
class IncompatibilityDialog extends StatelessWidget {
  const IncompatibilityDialog({super.key});

  /// Show the incompatibility dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const IncompatibilityDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Device Not Compatible',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room scanning is not available on this device.',
            style: TextStyle(fontSize: 16.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'Requirements:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '• iOS 16.0 or later\n• Device with LiDAR sensor\n• iPhone 12 Pro or newer',
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            'You can still proceed with photo-based estimates.',
            style: TextStyle(
              fontSize: 14.sp,
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
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
