import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

class InfoRowWidget extends StatelessWidget {
  final String label;
  final String? value;

  const InfoRowWidget({
    super.key,
    required this.label,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
              fontSize: 16,
            ),
          ),
          Text(
            value ?? '-',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
