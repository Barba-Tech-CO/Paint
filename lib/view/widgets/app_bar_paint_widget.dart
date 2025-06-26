import 'package:flutter/material.dart';

class AppBarPaintWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double toolbarHeight;

  const AppBarPaintWidget({
    super.key,
    required this.title,
    this.backgroundColor = const Color(0XFF4193FF),
    this.textColor = const Color(0XFFFFFFFF),
    this.toolbarHeight = 126,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 24,
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
