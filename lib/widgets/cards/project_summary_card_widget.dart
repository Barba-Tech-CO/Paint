import 'package:flutter/material.dart';

class ProjectSummaryCardWidget extends StatelessWidget {
  final String? title;
  final List<Widget> children;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool showShadow;
  final Color backgroundColor;
  final double borderRadius;

  const ProjectSummaryCardWidget({
    super.key,
    this.title,
    required this.children,
    this.padding,
    this.margin,
    this.showShadow = true,
    this.backgroundColor = Colors.white,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 12,
              top: 16,
            ),
            child: Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        Container(
          margin:
              margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: showShadow
                ? [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
