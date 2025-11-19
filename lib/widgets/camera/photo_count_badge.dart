import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';

class PhotoCountBadge extends StatelessWidget {
  final int extraCount;

  const PhotoCountBadge({
    super.key,
    required this.extraCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.gray24,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Text(
        '+ $extraCount',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.sp,
        ),
      ),
    );
  }
}
