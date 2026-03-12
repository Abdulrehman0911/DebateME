import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      textTheme: TextTheme(
        displayLarge: GoogleFonts.publicSans(color: AppColors.primaryText, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.publicSans(color: AppColors.primaryText, fontWeight: FontWeight.bold),
        bodyLarge: GoogleFonts.publicSans(color: AppColors.primaryText),
        bodyMedium: GoogleFonts.publicSans(color: AppColors.primaryText),
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
