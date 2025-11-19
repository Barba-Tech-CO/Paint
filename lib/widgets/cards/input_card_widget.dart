import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';

class InputCardWidget extends StatelessWidget {
  final String title;
  final String? description;
  final TextEditingController? controller;
  final String? hintText;
  final bool multiline;
  final int maxLines;
  final Widget? widget;
  final EdgeInsets padding;

  const InputCardWidget({
    super.key,
    required this.title,
    this.description,
    this.controller,
    this.hintText,
    this.multiline = false,
    this.maxLines = 1,
    this.widget,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          // Descrição (se fornecida)
          if (description != null && description!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
              child: Text(
                description!,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          // Campo de texto (se controller fornecido)
          if (controller != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
              child: TextField(
                controller: controller,
                maxLines: multiline ? maxLines : 1,
                keyboardType: multiline
                    ? TextInputType.multiline
                    : TextInputType.text,
                decoration: InputDecoration(
                  hintText: hintText,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2.w,
                    ),
                  ),
                ),
              ),
            ),

          // Widget opcional
          if (widget != null)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: widget!,
            ),
        ],
      ),
    );
  }
}
