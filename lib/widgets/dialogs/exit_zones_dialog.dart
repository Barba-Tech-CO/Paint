import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for confirming exit from zones
class ExitZonesDialog extends StatelessWidget {
  const ExitZonesDialog({super.key});

  /// Show the exit zones dialog
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const ExitZonesDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
