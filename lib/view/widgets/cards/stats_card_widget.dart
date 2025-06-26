import 'package:flutter/material.dart';

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
    this.titleFontSize = 24,
    this.descriptionFontSize = 12,
    this.width = 160,
    this.height = 95,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: descriptionFontSize,
                color: descriptionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
