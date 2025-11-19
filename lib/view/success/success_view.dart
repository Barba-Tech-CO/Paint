import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../../widgets/buttons/paint_pro_button.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(90.h),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 90.h,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(64.r),
              bottomRight: Radius.circular(64.r),
            ),
          ),
          title: Text(
            'Success!',
            style: GoogleFonts.albertSans(
              color: AppColors.textOnPrimary,
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Icon
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 60.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 32.h),

            // Success Message
            Text(
              'Estimate sent successfully!',
              style: GoogleFonts.albertSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),

            // Subtitle
            Text(
              'Project saved',
              style: GoogleFonts.albertSans(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 48.h),

            // OK Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: PaintProButton(
                text: 'Ok',
                onPressed: () => context.go('/home'),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                borderRadius: 12.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
