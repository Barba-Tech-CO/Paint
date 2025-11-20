import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';

/// Dialog for deleting quotes
class DeleteQuoteDialog extends StatelessWidget {
  final String quoteName;

  const DeleteQuoteDialog({
    super.key,
    required this.quoteName,
  });

  /// Show the delete quote dialog
  static Future<bool> show(
    BuildContext context, {
    required String quoteName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteQuoteDialog(quoteName: quoteName),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete Quote',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
          color: AppColors.textPrimary,
        ),
      ),
      content: Text(
        'Are you sure you want to delete this quote?',
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
              color: AppColors.gray100,
              fontSize: 14.sp,
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
