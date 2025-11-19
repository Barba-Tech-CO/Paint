import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SurfaceAreasWidget extends StatelessWidget {
  final Map<String, String> surfaceData;
  final String totalPaintableLabel;
  final String totalPaintableValue;
  final Color valueColor;
  final Color totalValueColor;
  final double fontSize;
  final double totalFontSize;
  final EdgeInsets padding;
  final bool showTitle;
  final String title;

  const SurfaceAreasWidget({
    super.key,
    required this.surfaceData,
    required this.totalPaintableLabel,
    required this.totalPaintableValue,
    this.valueColor = Colors.black54,
    this.totalValueColor = const Color(0xFF1A73E8),
    this.fontSize = 16,
    this.totalFontSize = 18,
    this.padding = const EdgeInsets.all(20),
    this.showTitle = true,
    this.title = 'Surface Areas',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12.h),
        ],
        Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Renderiza cada item das surface areas
              ...surfaceData.entries.map((entry) {
                return Column(
                  children: [
                    _buildSurfaceRow(entry.key, entry.value),
                    if (entry != surfaceData.entries.last)
                      SizedBox(height: 12.h),
                  ],
                );
              }),

              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 16.h),

              // Total Paintable
              Row(
                children: [
                  Text(
                    totalPaintableLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    totalPaintableValue,
                    style: TextStyle(
                      color: totalValueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: totalFontSize.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSurfaceRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize.sp,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize.sp,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
