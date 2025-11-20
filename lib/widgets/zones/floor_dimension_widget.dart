import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';

class FloorDimensionWidget extends StatefulWidget {
  final double? width;
  final double? length;
  final Function(double width, double length)? onDimensionChanged;

  const FloorDimensionWidget({
    super.key,
    this.width,
    this.length,
    this.onDimensionChanged,
  });

  @override
  State<FloorDimensionWidget> createState() => _FloorDimensionWidgetState();
}

class _FloorDimensionWidgetState extends State<FloorDimensionWidget> {
  late TextEditingController _widthController;
  late TextEditingController _lengthController;

  double get totalArea {
    final width = double.tryParse(_widthController.text) ?? 0;
    final length = double.tryParse(_lengthController.text) ?? 0;
    return width * length;
  }

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController(
      text: widget.width?.toString() ?? '',
    );
    _lengthController = TextEditingController(
      text: widget.length?.toString() ?? '',
    );

    _widthController.addListener(_onDimensionUpdate);
    _lengthController.addListener(_onDimensionUpdate);
  }

  void _onDimensionUpdate() {
    final width = double.tryParse(_widthController.text) ?? 0;
    final length = double.tryParse(_lengthController.text) ?? 0;
    widget.onDimensionChanged?.call(width, length);
    setState(() {}); // Update the total area display
  }

  @override
  void dispose() {
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Header with total area
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Floor Dimensions:',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${totalArea.toStringAsFixed(0)} sq ft',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16.h,
        ),

        // Dimension input fields
        Row(
          spacing: 16.w,
          children: [
            Expanded(
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.gray24,
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _widthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Width (ft)',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            // X separator
            Expanded(
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.gray24,
                  ),
                ),
                child: Center(
                  child: Text(
                    'X',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Length field
            Expanded(
              child: Container(
                height: 44.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.gray24,
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: TextField(
                    controller: _lengthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Length (ft)',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
