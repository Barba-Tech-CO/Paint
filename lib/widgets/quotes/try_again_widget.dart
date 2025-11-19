import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../buttons/paint_pro_button.dart';

class TryAgainWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const TryAgainWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error to load quotes',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Check your connection and try again',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16.h),
          PaintProButton(
            text: 'Try Again',
            minimumSize: Size(130.w, 42.h),
            borderRadius: 16.r,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}
