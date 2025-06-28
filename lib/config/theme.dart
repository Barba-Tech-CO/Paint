import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get themeData => ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.success,
      error: AppColors.error,
      surface: AppColors.surface,
      background: AppColors.background,
    ),
    textTheme: GoogleFonts.albertSansTextTheme().copyWith(
      displayLarge: GoogleFonts.albertSans(color: AppColors.textPrimary),
      displayMedium: GoogleFonts.albertSans(color: AppColors.textPrimary),
      displaySmall: GoogleFonts.albertSans(color: AppColors.textPrimary),
      headlineLarge: GoogleFonts.albertSans(color: AppColors.textPrimary),
      headlineMedium: GoogleFonts.albertSans(color: AppColors.textPrimary),
      headlineSmall: GoogleFonts.albertSans(color: AppColors.textPrimary),
      titleLarge: GoogleFonts.albertSans(color: AppColors.textPrimary),
      titleMedium: GoogleFonts.albertSans(color: AppColors.textPrimary),
      titleSmall: GoogleFonts.albertSans(color: AppColors.textPrimary),
      bodyLarge: GoogleFonts.albertSans(color: AppColors.textPrimary),
      bodyMedium: GoogleFonts.albertSans(color: AppColors.textPrimary),
      bodySmall: GoogleFonts.albertSans(color: AppColors.textSecondary),
      labelLarge: GoogleFonts.albertSans(color: AppColors.textPrimary),
      labelMedium: GoogleFonts.albertSans(color: AppColors.textSecondary),
      labelSmall: GoogleFonts.albertSans(color: AppColors.textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      titleTextStyle: GoogleFonts.albertSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.textOnPrimary,
        textStyle: GoogleFonts.albertSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
