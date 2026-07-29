import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_light_colors.dart';
import 'app_dark_colors.dart';

class AppTheme {
  // =========================
  // LIGHT THEME
  // =========================
  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Inter',

    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppLightColors.scaffold,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      background: AppLightColors.background,
      surface: AppLightColors.card,
      error: AppColors.error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppLightColors.background,
      elevation: 0,
      foregroundColor: AppLightColors.textPrimary,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppLightColors.textPrimary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppLightColors.textSecondary,
        fontSize: 12,
      ),
    ),
  );

  // =========================
  // DARK THEME
  // =========================
  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Inter',

    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppDarkColors.scaffold,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      background: AppDarkColors.background,
      surface: AppDarkColors.card,
      error: AppColors.error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppDarkColors.background,
      elevation: 0,
      foregroundColor: AppDarkColors.textPrimary,
    ),

    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppDarkColors.textPrimary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppDarkColors.textSecondary,
        fontSize: 12,
      ),
    ),
  );
}