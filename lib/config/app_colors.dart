import 'package:flutter/material.dart';

/// Painter Pro App Color Palette
/// Design System with consistent colors across the application
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF4193FF);
  static const Color primaryDark = Color(0xFF252526);
  static const Color primaryLight = Color(0xFFFFFFFF);

  // Secondary Colors
  static const Color success = Color(0xFF39D86E);
  static const Color warning = Color(0xFFFFEC5C);
  static const Color error = Color(0xFFFF7260);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE5E5E5);

  // Text Colors
  static const Color textPrimary = Color(0xFF252526);
  static const Color textSecondary = Color(0xFF8A8A8A);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Interactive Colors
  static const Color buttonPrimary = Color(0xFF4193FF);
  static const Color buttonSuccess = Color(0xFF39D86E);
  static const Color buttonWarning = Color(0xFFFFEC5C);
  static const Color buttonError = Color(0xFFFF7260);

  // Navigation Colors
  static const Color navigationActive = Color(0xFF4193FF);
  static const Color navigationInactive = Color(0xFF8A8A8A);
  static const Color navigationBackground = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusActive = Color(0xFF39D86E);
  static const Color statusPending = Color(0xFFFFEC5C);
  static const Color statusError = Color(0xFFFF7260);
  static const Color statusInactive = Color(0xFF8A8A8A);

  // Card Colors
  static const Color cardDefault = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF252526);
  static const Color cardSuccess = Color(0xFF39D86E);
  static const Color cardWarning = Color(0xFFFFEC5C);
  static const Color cardError = Color(0xFFFF7260);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4193FF), Color(0xFF2D6BFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF39D86E), Color(0xFF2BC653)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
