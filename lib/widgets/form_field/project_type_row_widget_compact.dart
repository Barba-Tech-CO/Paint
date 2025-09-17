import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ProjectTypeRowWidgetCompact extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const ProjectTypeRowWidgetCompact({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Primeira linha: Interior e Exterior
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Radio(
              value: 'Interior',
              groupValue: selectedType,
              onChanged: (value) {
                onTypeChanged(value.toString());
              },
              activeColor: AppColors.primary,
            ),
            const Text('Interior'),
            Radio(
              value: 'Exterior',
              groupValue: selectedType,
              onChanged: (value) {
                onTypeChanged(value.toString());
              },
              activeColor: AppColors.primary,
            ),
            const Text('Exterior'),
          ],
        ),
        // Segunda linha: Both
        Row(
          children: [
            Radio(
              value: 'Both',
              groupValue: selectedType,
              onChanged: (value) {
                onTypeChanged(value.toString());
              },
              activeColor: AppColors.primary,
            ),
            const Text('Both'),
          ],
        ),
      ],
    );
  }
}
