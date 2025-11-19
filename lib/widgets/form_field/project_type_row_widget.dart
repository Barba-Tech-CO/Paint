import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class ProjectTypeRowWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const ProjectTypeRowWidget({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
        const SizedBox(width: 16),
        Radio(
          value: 'Exterior',
          groupValue: selectedType,
          onChanged: (value) {
            onTypeChanged(value.toString());
          },
          activeColor: AppColors.primary,
        ),
        const Text('Exterior'),
        const SizedBox(width: 16),
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
    );
  }
}
