import 'package:flutter/material.dart';

import '../../../core/config/app_colors.dart';

class FloatingCameraButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final String? semanticsLabel;
  const FloatingCameraButtonWidget({
    super.key,
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
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.buttonPrimary,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primaryLight,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt,
            color: AppColors.textOnPrimary,
            size: 36,
          ),
        ),
      ),
    );
  }
}
