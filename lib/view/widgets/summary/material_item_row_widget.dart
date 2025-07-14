import 'package:flutter/material.dart';

class MaterialItemRowWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final Color priceColor;
  final EdgeInsets padding;
  final double titleFontSize;
  final double subtitleFontSize;
  final double priceFontSize;

  const MaterialItemRowWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.price,
    this.priceColor = Colors.blue,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.titleFontSize = 16,
    this.subtitleFontSize = 14,
    this.priceFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: priceFontSize,
              fontWeight: FontWeight.w600,
              color: priceColor,
            ),
          ),
        ],
      ),
    );
  }
}
