import 'package:flutter/material.dart';

class RoomOverviewRowWidget extends StatelessWidget {
  final String leftTitle;
  final String leftSubtitle;
  final String rightTitle;
  final String rightSubtitle;
  final Color titleColor;
  final Color subtitleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final EdgeInsets padding;

  const RoomOverviewRowWidget({
    super.key,
    required this.leftTitle,
    required this.leftSubtitle,
    required this.rightTitle,
    required this.rightSubtitle,
    this.titleColor = Colors.blue,
    this.subtitleColor = Colors.grey,
    this.titleFontSize = 18,
    this.subtitleFontSize = 16,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  leftTitle,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  leftSubtitle,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  rightTitle,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  rightSubtitle,
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: subtitleColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
