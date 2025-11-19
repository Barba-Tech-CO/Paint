import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

class SectionHeaderWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  const SectionHeaderWidget({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
