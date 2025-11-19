import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GreetingCardWidget extends StatelessWidget {
  final String greeting;
  final String name;
  final EdgeInsets padding;
  final double height;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets innerPadding;

  const GreetingCardWidget({
    super.key,
    required this.greeting,
    required this.name,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
    this.height = 64,
    this.borderColor = const Color(0XFFE8E8E8),
    this.borderWidth = 1,
    this.borderRadius = 16,
    this.innerPadding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        height: height.h,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            width: borderWidth.w,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
        child: Padding(
          padding: innerPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
