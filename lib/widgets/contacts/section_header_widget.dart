import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';

class SectionHeaderWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  const SectionHeaderWidget({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 18.sp,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
