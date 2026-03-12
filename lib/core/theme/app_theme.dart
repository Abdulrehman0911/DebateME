import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.accent,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        surface: AppColors.surface,
        onPrimary: AppColors.primaryText,
        onSurface: AppColors.primaryText,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.w900, fontFamily: 'Public Sans'),
        displayMedium: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontFamily: 'Public Sans'),
        bodyLarge: TextStyle(color: AppColors.primaryText, fontFamily: 'Public Sans'),
        bodyMedium: TextStyle(color: AppColors.primaryText, fontFamily: 'Public Sans'),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      dividerColor: AppColors.divider,
    );
  }
}
