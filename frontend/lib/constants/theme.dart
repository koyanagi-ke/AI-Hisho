import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData getTheme(String colorName) {
    final Color primaryColor =
        AppColors.themeColors[colorName] ?? AppColors.themeColors['orange']!;

    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: AppColors.gray50,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.gray50,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: const TextStyle(
          color: AppColors.gray900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.gray900,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.gray900,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.gray900,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.gray600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.gray700,
          backgroundColor: AppColors.gray200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
