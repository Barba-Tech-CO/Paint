import 'package:flutter/material.dart';

class BuildChipWidget extends StatelessWidget {
  final String text;
  final Color textColor;

  const BuildChipWidget({
    super.key,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
