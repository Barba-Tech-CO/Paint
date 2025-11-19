import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return RadioGroup<String>(
      onChanged: (value) {
        if (value != null) {
          onTypeChanged(value);
        }
      },
      child: Row(
        children: [
          Radio<String>(
            value: 'Interior',
            toggleable: selectedType == 'Interior',
            activeColor: AppColors.primary,
          ),
          const Text('Interior'),
          SizedBox(width: 16.w),
          Radio<String>(
            value: 'Exterior',
            toggleable: selectedType == 'Exterior',
            activeColor: AppColors.primary,
          ),
          const Text('Exterior'),
          SizedBox(width: 16.w),
          Radio<String>(
            value: 'Both',
            toggleable: selectedType == 'Both',
            activeColor: AppColors.primary,
          ),
          const Text('Both'),
        ],
      ),
    );
  }
}
