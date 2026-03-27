import 'package:flutter/material.dart';

class AppColors {
  // === Cyberpunk Core Palette ===
  static const Color deepVoid = Color(0xFF09090E);
  static const Color darkAbyss = Color(0xFF1A1A2E);
  static const Color neonPurple = Color(0xFFB829EA);
  static const Color electricBlue = Color(0xFF00E5FF);

  // === Surface & Card ===
  static const Color glassSurface = Color(0xFF171721);
  static const Color surface = Color(0xFF12121C);
  static const Color divider = Color(0xFF2A2A3D);

  // === Text ===
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color mutedText = Color(0xFF8A8A9D);

  // === Semantic ===
  static const Color victory = Color(0xFF00FF88);
  static const Color defeat = Color(0xFFFF3366);
  static const Color draw = Color(0xFFFFAA00);

  // === Legacy aliases (prevents breaks in unedited files) ===
  static const Color background = deepVoid;
  static const Color accent = neonPurple;
  static const Color secondaryText = mutedText;
  static const Color premiumBlue = electricBlue;

  // === Gradients ===
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepVoid, darkAbyss],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonPurple, electricBlue],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B1FA0), neonPurple],
  );
}
