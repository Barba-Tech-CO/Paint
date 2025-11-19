import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';

class PaintProAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double toolbarHeight;
  final Widget? leading;
  final double? leadingWidth;
  final List<Widget>? actions;

  PaintProAppBar({
    super.key,
    required this.title,
    this.leading,
    this.leadingWidth,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    double? toolbarHeight,
    this.actions,
  }) : toolbarHeight = toolbarHeight ?? 80.h;

  @override
  Widget build(BuildContext context) {
    List<Widget>? paddedActions;
    if (actions != null && actions!.isNotEmpty) {
      paddedActions = actions!.asMap().entries.map((entry) {
        final isLast = entry.key == actions!.length - 1;
        return Padding(
          padding: EdgeInsets.only(right: isLast ? 8.w : 0),
          child: entry.value,
        );
      }).toList();
    }

    return AppBar(
      leading: leading,
      leadingWidth: leadingWidth,
      title: Text(
        title,
        style: GoogleFonts.albertSans(
          fontSize: 24.sp,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      toolbarHeight: toolbarHeight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(64.r),
          bottomRight: Radius.circular(64.r),
        ),
      ),
      actions: paddedActions,
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(toolbarHeight);
  }
}
