import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaintProPhoneField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final bool isEnabled;
  final FocusNode? focusNode;

  const PaintProPhoneField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.isEnabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Phone input field
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.phone,
          validator: validator,
          enabled: isEnabled,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            // You could add a custom formatter for phone numbers
          ],
          focusNode: focusNode,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText ?? '+1 (555) 123-4567',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          style: theme.textTheme.bodyMedium,
        ),

        // Add some bottom spacing
        const SizedBox(height: 16),
      ],
    );
  }
}
