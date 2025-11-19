import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaintProPasswordField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final bool isEnabled;
  final FocusNode? focusNode;

  const PaintProPasswordField({
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
  State<PaintProPasswordField> createState() => _PaintProPasswordFieldState();
}

class _PaintProPasswordFieldState extends State<PaintProPasswordField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
            widget.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
        ),

        // Password input field
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          keyboardType: TextInputType.visiblePassword,
          validator: widget.validator,
          enabled: widget.isEnabled,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFE0E0E0),
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFE0E0E0),
                width: 1.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.red,
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2.w,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
                size: 20.sp,
              ),
              onPressed: widget.isEnabled ? _toggleVisibility : null,
            ),
          ),
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
        ),

        // Add some bottom spacing
        SizedBox(height: 16.h),
      ],
    );
  }
}
