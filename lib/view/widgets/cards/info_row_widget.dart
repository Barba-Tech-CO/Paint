import 'package:flutter/material.dart';

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
    final displayValue = value?.isNotEmpty == true ? value! : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              displayValue,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: displayValue == '-' ? Colors.grey[500] : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
