import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectSummaryCardWidget extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showShadow;
  final Color backgroundColor;
  final double borderRadius;

  const ProjectSummaryCardWidget({
    super.key,
    this.title,
    required this.children,
    this.padding,
    this.margin,
    this.showShadow = true,
    this.backgroundColor = Colors.white,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
              top: 16.h,
            ),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        Container(
          margin:
              margin ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          padding: padding ?? EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius.r),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      spreadRadius: 2.r,
                      blurRadius: 8.r,
                      offset: Offset(0, 6.h),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
