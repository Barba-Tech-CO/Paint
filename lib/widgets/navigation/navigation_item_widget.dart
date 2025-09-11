import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../../model/navigation/navigation_item_model.dart';

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
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive
                    ? AppColors.navigationActive
                    : AppColors.navigationInactive,
                size: 26,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  item.label,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
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
