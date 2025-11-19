import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';

class CameraControlButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color? backgroundColor;
  final double size;

  const CameraControlButton({
    super.key,
    this.onTap,
    required this.child,
    this.backgroundColor,
    this.size = 48,
  });

  factory CameraControlButton.zoom({
    Key? key,
    VoidCallback? onTap,
    String zoomText = '2x',
  }) {
    return CameraControlButton(
      key: key,
      onTap: onTap,
      backgroundColor: AppColors.textPrimary.withValues(alpha: 0.75),
      child: Center(
        child: Text(
          zoomText,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  factory CameraControlButton.flash({
    Key? key,
    required VoidCallback onTap,
    required bool isFlashOn,
  }) {
    return CameraControlButton(
      key: key,
      onTap: onTap,
      backgroundColor: isFlashOn
          ? AppColors.primary
          : AppColors.textPrimary.withValues(alpha: 0.8),
      child: Center(
        child: Icon(
          isFlashOn ? Icons.flash_on : Icons.flash_off,
          color: Colors.white,
          size: 26.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.h,
        decoration: BoxDecoration(
          color:
              backgroundColor ?? AppColors.textPrimary.withValues(alpha: 0.75),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}
