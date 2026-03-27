import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color glowColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double glowIntensity;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 48,
    this.glowColor = const Color(0xFFB829EA),
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.w900,
    this.glowIntensity = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Bottom layer: blurred glow
        ImageFiltered(
          imageFilter: ImageFilter.blur(
            sigmaX: glowIntensity,
            sigmaY: glowIntensity,
          ),
          child: Text(
            text,
            style: GoogleFonts.spaceGrotesk(
              color: glowColor.withOpacity(0.8),
              fontSize: fontSize,
              fontWeight: fontWeight,
              fontStyle: FontStyle.italic,
              height: 0.9,
            ),
          ),
        ),
        // Top layer: crisp text
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            color: textColor,
            fontSize: fontSize,
            fontWeight: fontWeight,
            fontStyle: FontStyle.italic,
            height: 0.9,
          ),
        ),
      ],
    );
  }
}
