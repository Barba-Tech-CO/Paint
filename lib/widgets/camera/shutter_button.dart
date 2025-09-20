import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

class ShutterButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double outerSize;
  final double innerSize;
  final Color borderColor;
  final Color innerColor;
  final double borderWidth;
  final Widget? child;
  final bool isDisabled;

  const ShutterButton({
    super.key,
    this.onTap,
    this.outerSize = 72,
    this.innerSize = 52,
    this.borderColor = Colors.white,
    this.innerColor = AppColors.primary,
    this.borderWidth = 4,
    this.child,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = isDisabled
        ? AppColors.gray100
        : borderColor;
    final Color effectiveInnerColor = isDisabled
        ? AppColors.gray100
        : innerColor;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: effectiveBorderColor,
            width: borderWidth,
          ),
        ),
        child: Container(
          width: innerSize,
          height: innerSize,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: effectiveInnerColor,
            shape: BoxShape.circle,
          ),
          child: child,
        ),
      ),
    );
  }
}
