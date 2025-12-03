import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final Color backgroundColor;
  final Color titleColor;
  final Color descriptionColor;
  final double titleFontSize;
  final double descriptionFontSize;
  final double width;
  final double height;
  final double borderRadius;

  const StatsCardWidget({
    super.key,
    required this.title,
    required this.description,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.titleColor = Colors.black,
    this.descriptionColor = Colors.grey,
    this.titleFontSize = 20,
    this.descriptionFontSize = 12,
    this.width = 180,
    this.height = 95,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width.w,
      height: height.h,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1.r,
            blurRadius: 3.r,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize.sp,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: TextStyle(
                fontSize: descriptionFontSize.sp,
                color: descriptionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
