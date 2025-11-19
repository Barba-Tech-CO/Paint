import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'color_card_widget.dart';

class ColorGridWidget extends StatelessWidget {
  final String brand;
  final List<Map<String, dynamic>> colors;
  final Function(Map<String, dynamic>)? onColorTap;

  const ColorGridWidget({
    super.key,
    required this.brand,
    required this.colors,

    this.onColorTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Notes",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              return ColorCardWidget(
                name: color['name'] ?? '',
                code: color['code'] ?? '',
                price: color['price'] ?? '',
                color: color['color'],
                onTap: () => onColorTap?.call(color),
              );
            },
          ),
        ],
      ),
    );
  }
}
