import 'package:flutter/material.dart';

class ProjectCostSummaryWidget extends StatelessWidget {
  final String title;
  final String cost;
  final String timeline;
  final Color costColor;
  final Color timelineColor;
  final double titleFontSize;
  final double costFontSize;
  final double timelineFontSize;

  const ProjectCostSummaryWidget({
    super.key,
    required this.title,
    required this.cost,
    required this.timeline,
    this.costColor = Colors.blue,
    this.timelineColor = Colors.grey,
    this.titleFontSize = 18,
    this.costFontSize = 32,
    this.timelineFontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              cost,
              style: TextStyle(
                fontSize: costFontSize,
                fontWeight: FontWeight.bold,
                color: costColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeline,
              style: TextStyle(
                fontSize: timelineFontSize,
                color: timelineColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
