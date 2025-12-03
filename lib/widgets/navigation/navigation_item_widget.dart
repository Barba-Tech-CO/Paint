import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../../model/navigation/navigation_item_model.dart';
import 'navigation_item_icon.dart';

class NavigationItemWidget extends StatelessWidget {
  final NavigationItemModel item;
  final bool isActive;
  final int index;
  final void Function()? onTap;
  final String? semanticsLabel;

  const NavigationItemWidget({
    super.key,
    required this.item,
    required this.isActive,
    required this.index,
    this.onTap,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              NavigationItemIcon(
                item: item,
                isActive: isActive,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  item.label,
                  style: GoogleFonts.albertSans(
                    fontSize: 12.sp,
                    color: isActive
                        ? AppColors.navigationActive
                        : AppColors.navigationInactive,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
