import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/app_colors.dart';

class PaintProAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double toolbarHeight;
  final Widget? leading;
  final double? leadingWidth;
  final List<Widget>? tabs;
  final TabController? controller;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final Widget? actions;

  const PaintProAppBar({
    super.key,
    required this.title,
    this.leading,
    this.leadingWidth,
    this.backgroundColor = AppColors.primary,
    this.textColor = AppColors.textOnPrimary,
    this.toolbarHeight = 80,
    this.tabs,
    this.controller,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.actions,
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

    List<Widget>? paddedActions;
    if (actions != null) {
      paddedActions = [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: actions,
        ),
      ];
    }

    if (tabs == null) {
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
        actions: paddedActions,
      );
    }

    // AppBar com TabBar integrado
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
      actions: paddedActions,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TabBar(
            controller: controller,
            tabs: tabs!,
            indicatorColor: indicatorColor ?? Colors.white,
            indicatorWeight: 3.0,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: const EdgeInsets.only(bottom: 4.0),
            labelColor: labelColor ?? textColor,
            unselectedLabelColor:
                unselectedLabelColor ?? textColor.withAlpha(7),
            labelStyle: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.albertSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            dividerColor: Colors.transparent,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    // Ajusta o tamanho preferido baseado se há tabs ou não
    final double height = tabs != null && tabs!.isNotEmpty
        ? toolbarHeight +
              48.0 // Altura adicional para as tabs
        : toolbarHeight;
    return Size.fromHeight(height);
  }
}
