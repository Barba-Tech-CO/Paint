import 'package:flutter/material.dart';
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

  const PaintProAppBar({
    super.key,
    required this.title,
    this.leading,
    this.leadingWidth,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.toolbarHeight = 80,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget>? paddedActions;
    if (actions != null && actions!.isNotEmpty) {
      paddedActions = actions!.asMap().entries.map((entry) {
        final isLast = entry.key == actions!.length - 1;
        return Padding(
          padding: EdgeInsets.only(right: isLast ? 8.0 : 0.0),
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
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      centerTitle: true,
      backgroundColor: backgroundColor,
      toolbarHeight: toolbarHeight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(64),
          bottomRight: Radius.circular(64),
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
