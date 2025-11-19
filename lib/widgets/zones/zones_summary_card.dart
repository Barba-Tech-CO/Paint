import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ZonesSummaryCardState { normal, noZones }

class ZonesSummaryCard extends StatelessWidget {
  final String avgDimensions;
  final String totalArea;
  final String totalPaintable;
  final VoidCallback? onAdd;
  final ZonesSummaryCardState state;

  const ZonesSummaryCard({
    super.key,
    required this.avgDimensions,
    required this.totalArea,
    required this.totalPaintable,
    this.onAdd,
    this.state = ZonesSummaryCardState.normal,
  });

  @override
  Widget build(BuildContext context) {
    final bool showAddButton = state == ZonesSummaryCardState.normal;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(top: 24.h),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 16.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          avgDimensions,
                          style: TextStyle(
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Average Dimensions',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          totalArea,
                          style: TextStyle(
                            color: Color(0xFF1A73E8),
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Total Floor Area',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              const Divider(),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Total Paintable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),

                  Text(
                    totalPaintable,
                    style: TextStyle(
                      color: Color(0xFF1A73E8),
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showAddButton)
          Positioned(
            top: 8.h,
            right: 8.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: onAdd,
                child: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 32.sp),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
