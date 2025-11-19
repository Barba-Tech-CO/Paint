import 'package:flutter/material.dart';

class SummaryInfoRowWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? labelColor;
  final Color? valueColor;
  final double fontSize;
  final EdgeInsets padding;

  const SummaryInfoRowWidget({
    super.key,
    required this.label,
    required this.value,
    this.isBold = false,
    this.labelColor,
    this.valueColor,
    this.fontSize = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: labelColor ?? Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: valueColor ?? Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
