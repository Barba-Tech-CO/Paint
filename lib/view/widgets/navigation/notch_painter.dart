import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

class NotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.navigationBackground
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Notch width and position
    double notchWidth = 90;
    double notchHeight = 35;
    double notchMargin = (size.width - notchWidth) / 2;

    // Draw navbar outline with notch
    path.moveTo(0, notchHeight);
    path.lineTo(notchMargin - 10, notchHeight);

    // Left notch curve
    path.quadraticBezierTo(
      notchMargin,
      notchHeight,
      notchMargin + 10,
      notchHeight - 10,
    );

    // Top notch curve
    path.quadraticBezierTo(
      notchMargin + notchWidth / 2,
      -5,
      notchMargin + notchWidth - 10,
      notchHeight - 10,
    );

    // Right notch curve
    path.quadraticBezierTo(
      notchMargin + notchWidth,
      notchHeight,
      notchMargin + notchWidth + 10,
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
