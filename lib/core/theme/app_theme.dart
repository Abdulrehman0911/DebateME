import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      primaryColor: AppColors.neonPurple,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonPurple,
        secondary: AppColors.electricBlue,
        surface: AppColors.surface,
        onPrimary: AppColors.primaryText,
        onSurface: AppColors.primaryText,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w900,
          fontSize: 48,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displaySmall: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
          fontSize: 24,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        titleLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        titleMedium: GoogleFonts.outfit(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: AppColors.primaryText,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: AppColors.primaryText,
          fontSize: 14,
        ),
        bodySmall: GoogleFonts.outfit(
          color: AppColors.mutedText,
          fontSize: 12,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w800,
          fontSize: 14,
          letterSpacing: 1.5,
        ),
        labelSmall: GoogleFonts.outfit(
          color: AppColors.mutedText,
          fontWeight: FontWeight.w600,
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: AppColors.primaryText,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: AppColors.mutedText),
      ),
      dividerColor: AppColors.divider,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.neonPurple,
        contentTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
