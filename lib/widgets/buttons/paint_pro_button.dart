import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';

enum ButtonState { enabled, disabled, loading }

class PaintProButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final Size? minimumSize;
  final double borderRadius;
  final bool isLoading;
  final Widget? icon;
  final TextStyle? textStyle;
  final ButtonState state;

  PaintProButton({
    super.key,
    required this.text,
    this.state = ButtonState.enabled,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    EdgeInsets? padding,
    Size? minimumSize,
    double? borderRadius,
    this.isLoading = false,
    this.icon,
    this.textStyle,
  }) : padding =
           padding ?? EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
       minimumSize = minimumSize ?? Size(double.infinity, 48.h),
       borderRadius = borderRadius ?? 12.r;

  bool get _isEnabled => state == ButtonState.enabled;
  bool get _isLoading => state == ButtonState.loading;

  Color _getBackgroundColor(BuildContext context) {
    final base = backgroundColor ?? AppColors.primary;
    return _isEnabled ? base : base.withValues(alpha: 0.5);
  }

  Color _getForegroundColor(BuildContext context) {
    final base = foregroundColor ?? Colors.white;
    return _isEnabled ? base : base.withValues(alpha: 0.7);
  }

  double get _elevation => _isEnabled ? 2 : 0;

  TextStyle _getTextStyle(BuildContext context) {
    final base =
        textStyle ??
        TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        );
    return base.copyWith(
      color: _getForegroundColor(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: ElevatedButton(
        onPressed: _isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(context),
          foregroundColor: _getForegroundColor(context),
          minimumSize: minimumSize,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: _elevation,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    IconTheme(
                      data: IconThemeData(
                        color: _getForegroundColor(context),
                      ),
                      child: icon!,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  Text(
                    text,
                    style: _getTextStyle(context),
                  ),
                ],
              ),
      ),
    );
  }
}
