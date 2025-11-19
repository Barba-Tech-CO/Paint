import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';

class CameraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onDonePressed;
  final String instructionText;
  final bool isDoneEnabled;

  const CameraAppBar({
    super.key,
    this.onBackPressed,
    this.onDonePressed,
    this.instructionText = 'Take between 3 - 9 photos',
    this.isDoneEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8.w, 24.h, 8.w, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            _buildActionButton(
              onPressed: onBackPressed,
              icon: Icons.arrow_back_ios,
              label: 'Back',
              backgroundColor: AppColors.gray50,
            ),

            // Center Instruction Text
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8.0.w),
                padding: EdgeInsets.symmetric(
                  horizontal: 8.0.w,
                  vertical: 12.0.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray24,
                  borderRadius: BorderRadius.circular(20.0.r),
                ),
                child: Center(
                  child: Text(
                    instructionText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.albertSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // Done Button
            _buildActionButton(
              onPressed: isDoneEnabled ? onDonePressed : null,
              icon: Icons.arrow_forward_ios,
              label: 'Done',
              backgroundColor: isDoneEnabled
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.5),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0.w, vertical: 12.0.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.0.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_back_ios) ...[
              Icon(
                icon,
                size: 18.sp,
                color: textColor,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: GoogleFonts.albertSans(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            if (icon == Icons.arrow_forward_ios) ...[
              SizedBox(width: 4.w),
              Icon(
                icon,
                size: 18.sp,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.0.h);
}
