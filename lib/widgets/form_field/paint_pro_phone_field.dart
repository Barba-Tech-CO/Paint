import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          padding: EdgeInsets.only(bottom: 8.h),
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
            hintText: hintText ?? '+1 +1 (555) 123-4567',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey.shade100,
          ),
          style: theme.textTheme.bodyMedium,
        ),

        // Add some bottom spacing
        SizedBox(height: 16.h),
      ],
    );
  }
}
