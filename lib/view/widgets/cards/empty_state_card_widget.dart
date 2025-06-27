import 'package:flutter/material.dart';

enum EmptyStateType {
  empty,
  noData,
  error,
  loading,
}

class EmptyStateCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final EmptyStateType state;
  final EdgeInsets padding;
  final EdgeInsets containerPadding;
  final double titleFontSize;
  final double descriptionFontSize;
  final Color titleColor;
  final Color? descriptionColor;
  final Color buttonBackgroundColor;
  final Color buttonTextColor;
  final double buttonBorderRadius;
  final EdgeInsets buttonPadding;
  final Widget? customIcon;

  const EmptyStateCardWidget({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
    this.state = EmptyStateType.empty,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
    this.containerPadding = const EdgeInsets.symmetric(vertical: 40),
    this.titleFontSize = 18,
    this.descriptionFontSize = 14,
    this.titleColor = Colors.black,
    this.descriptionColor,
    this.customIcon,
    this.buttonBackgroundColor = const Color(0xFF4193FF),
    this.buttonTextColor = Colors.white,
    this.buttonBorderRadius = 24,
    this.buttonPadding = const EdgeInsets.symmetric(
      horizontal: 32,
      vertical: 16,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        padding: containerPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: descriptionFontSize,
                color: descriptionColor ?? Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBackgroundColor,
                  foregroundColor: buttonTextColor,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                ),
                child: Text(
                  buttonText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            if (state == EmptyStateType.loading) ...[
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}
