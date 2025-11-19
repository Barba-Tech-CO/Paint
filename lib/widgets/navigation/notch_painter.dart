import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';

class NotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.navigationBackground
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Notch width and position
    double notchWidth = 90.w;
    double notchHeight = 35.h;
    double notchMargin = (size.width - notchWidth) / 2;

    // Draw navbar outline with notch
    path.moveTo(0, notchHeight);
    path.lineTo(notchMargin - 10.w, notchHeight);

    // Left notch curve
    path.quadraticBezierTo(
      notchMargin,
      notchHeight,
      notchMargin + 10.w,
      notchHeight - 10.h,
    );

    // Top notch curve
    path.quadraticBezierTo(
      notchMargin + notchWidth / 2,
      -5.h,
      notchMargin + notchWidth - 10.w,
      notchHeight - 10.h,
    );

    // Right notch curve
    path.quadraticBezierTo(
      notchMargin + notchWidth,
      notchHeight,
      notchMargin + notchWidth + 10.w,
      notchHeight,
    );

    path.lineTo(size.width, notchHeight);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
