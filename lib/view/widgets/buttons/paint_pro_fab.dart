import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class PaintProFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const PaintProFAB({
    super.key,
    required this.onPressed,
    this.icon = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      child: Icon(
        icon,
        color: AppColors.cardDefault,
        size: 40,
      ),
    );
  }
}
