import 'package:flutter/material.dart';
import '../../../config/app_colors.dart';

class DropDownFilterWidget<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final Widget Function(T) itemBuilder;

  const DropDownFilterWidget({
    super.key,
    this.value,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T?>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          hint: Text('Select $label'),
          items: [
            DropdownMenuItem<T?>(
              value: null,
              child: Text('All ${label}s'),
            ),
            ...items.map(
              (item) => DropdownMenuItem<T?>(
                value: item,
                child: itemBuilder(item),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
