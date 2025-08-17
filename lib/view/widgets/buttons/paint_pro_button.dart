import 'package:flutter/material.dart';

import '../../../config/app_colors.dart';

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

  const PaintProButton({
    super.key,
    required this.text,
    this.state = ButtonState.enabled,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = const EdgeInsets.only(left: 16, right: 16, bottom: 16),
    this.minimumSize = const Size(double.infinity, 48),
    this.borderRadius = 12,
    this.isLoading = false,
    this.icon,
    this.textStyle,
  });

  bool get _isEnabled => state == ButtonState.enabled;
  bool get _isLoading => state == ButtonState.loading;

  Color _getBackgroundColor(BuildContext context) {
    final base = backgroundColor ?? AppColors.primary;
    return _isEnabled ? base : base.withValues(alpha: 0.5);
  }

  Color _getForegroundColor(BuildContext context) {
    final base = foregroundColor ?? AppColors.textOnPrimary;
    return _isEnabled ? base : base.withValues(alpha: 0.7);
  }

  double get _elevation => _isEnabled ? 2 : 0;

  TextStyle _getTextStyle(BuildContext context) {
    final base =
        textStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
    return base.copyWith(color: _getForegroundColor(context));
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
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    IconTheme(
                      data: IconThemeData(color: _getForegroundColor(context)),
                      child: icon!,
                    ),
                    const SizedBox(width: 8),
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
