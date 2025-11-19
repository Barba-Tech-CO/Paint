import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

class PhotoCountBadge extends StatelessWidget {
  final int extraCount;

  const PhotoCountBadge({
    super.key,
    required this.extraCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gray24,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Text(
        '+ $extraCount',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
