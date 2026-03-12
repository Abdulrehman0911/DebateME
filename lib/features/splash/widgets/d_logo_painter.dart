import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.primaryText
      ..style = PaintingStyle.fill;

    // 1. Create the base 'D' shape (Bold and Solid)
    final Path dPath = Path();
    final double l = size.width * 0.15; // Left
    final double r = size.width * 0.95; // Right edge of curve
    final double t = size.height * 0.05; // Top
    final double b = size.height * 0.95; // Bottom
    final double curveStart = size.width * 0.5;

    dPath.moveTo(l, t);
    dPath.lineTo(curveStart, t);
    dPath.cubicTo(
      r, t, 
      r, b, 
      curveStart, b
    );
    dPath.lineTo(l, b);
    dPath.close();

    // 2. Create the precise Lightning Bolt path based on reference
    final Path boltPath = Path();
    // Start from top-center, slanted right to left
    boltPath.moveTo(size.width * 0.58, t - 5); 
    boltPath.lineTo(size.width * 0.42, size.height * 0.48);
    // Zigzag middle
    boltPath.lineTo(size.width * 0.58, size.height * 0.52);
    // Slant down to bottom right
    boltPath.lineTo(size.width * 0.42, b + 5);
    
    // Create thickness for the bolt
    boltPath.lineTo(size.width * 0.32, b + 5);
    boltPath.lineTo(size.width * 0.48, size.height * 0.52);
    boltPath.lineTo(size.width * 0.32, size.height * 0.48);
    boltPath.lineTo(size.width * 0.48, t - 5);
    boltPath.close();

    // 3. Combine for true cutout
    final Path finalPath = Path.combine(
      PathOperation.difference,
      dPath,
      boltPath,
    );

    canvas.drawPath(finalPath, paint);

    // 4. Subtle center accent (Orange as requested in first redesign)
    final Paint accentPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

    final Path accent = Path();
    accent.moveTo(size.width * 0.48, size.height * 0.52);
    accent.lineTo(size.width * 0.42, size.height * 0.48);
    accent.lineTo(size.width * 0.45, size.height * 0.47);
    accent.lineTo(size.width * 0.51, size.height * 0.51);
    accent.close();
    
    canvas.drawPath(accent, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
