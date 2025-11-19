import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';
import '../../model/navigation/navigation_item_model.dart';

class NavigationItemIcon extends StatelessWidget {
  final NavigationItemModel item;
  final bool isActive;

  const NavigationItemIcon({
    super.key,
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppColors.navigationActive
        : AppColors.navigationInactive;

    final assetPath = isActive
        ? item.activeIconAsset ?? item.iconAsset
        : item.iconAsset ?? item.activeIconAsset;

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        height: 26.h,
        width: 26.w,
        color: color,
      );
    }

    final iconData = isActive
        ? item.activeIcon ?? item.icon
        : item.icon ?? item.activeIcon;

    return Icon(
      iconData,
      color: color,
      size: 26.sp,
    );
  }
}
