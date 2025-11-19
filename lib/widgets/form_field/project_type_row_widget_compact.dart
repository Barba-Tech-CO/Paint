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
    return RadioGroup<String>(
      onChanged: (value) {
        if (value != null) {
          onTypeChanged(value);
        }
      },
      child: Column(
        children: [
          // Primeira linha: Interior e Exterior
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Radio<String>(
                value: 'Interior',
                toggleable: selectedType == 'Interior',
                activeColor: AppColors.primary,
              ),
              const Text('Interior'),
              Radio<String>(
                value: 'Exterior',
                toggleable: selectedType == 'Exterior',
                activeColor: AppColors.primary,
              ),
              const Text('Exterior'),
            ],
          ),
          // Segunda linha: Both
          Row(
            children: [
              Radio<String>(
                value: 'Both',
                toggleable: selectedType == 'Both',
                activeColor: AppColors.primary,
              ),
              const Text('Both'),
            ],
          ),
        ],
      ),
    );
  }
}
