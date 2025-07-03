import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paintpro/config/app_colors.dart';

class PaintProAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double toolbarHeight;
  final Widget? leading;
  final double? leadingWidth;

  const PaintProAppBar({
    super.key,
    required this.title,
    this.leading,
    this.leadingWidth,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.toolbarHeight = 126,
  });

  @override
  Widget build(BuildContext context) {
    Widget? paddedLeading;
    double? finalLeadingWidth;

    if (leading != null) {
      paddedLeading = Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: leading,
      );
      finalLeadingWidth = leadingWidth;
    }

    return AppBar(
      leading: paddedLeading,
      leadingWidth: finalLeadingWidth,
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
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}
