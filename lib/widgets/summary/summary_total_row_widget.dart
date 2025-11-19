import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SummaryTotalRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool showDivider;
  final EdgeInsets padding;
  final double fontSize;
  final FontWeight fontWeight;

  const SummaryTotalRowWidget({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = Colors.blue,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(
              height: 1.h,
              color: Colors.grey.shade300,
            ),
          ),
        Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: Colors.black87,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
