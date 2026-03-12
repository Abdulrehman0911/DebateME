import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background D shape
    final Path dPath = Path();
    dPath.moveTo(size.width * 0.2, size.height * 0.1);
    dPath.lineTo(size.width * 0.5, size.height * 0.1);
    
    // Create the right curve for 'D'
    dPath.cubicTo(
      size.width * 0.8, size.height * 0.1,  // Control point 1
      size.width * 1.0, size.height * 0.3,  // Control point 2
      size.width * 0.9, size.height * 0.5   // End point
    );
    
    dPath.cubicTo(
      size.width * 1.0, size.height * 0.7,
      size.width * 0.8, size.height * 0.9,
      size.width * 0.5, size.height * 0.9
    );
    
    dPath.lineTo(size.width * 0.2, size.height * 0.9);
    dPath.close();

    final Paint dShapePaint = Paint()
      ..color = AppColors.primaryText
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(dPath, dShapePaint);
    
    // Lightning Bolt cut-out (Black/Background)
    final Path boltPath = Path();
    boltPath.moveTo(size.width * 0.45, size.height * 0.1);
    boltPath.lineTo(size.width * 0.55, size.height * 0.45);
    boltPath.lineTo(size.width * 0.40, size.height * 0.55);
    boltPath.lineTo(size.width * 0.50, size.height * 0.9);
    boltPath.lineTo(size.width * 0.42, size.height * 0.9);
    boltPath.lineTo(size.width * 0.32, size.height * 0.55);
    boltPath.lineTo(size.width * 0.47, size.height * 0.45);
    boltPath.lineTo(size.width * 0.37, size.height * 0.1);
    boltPath.close();

    final Paint boltPaint = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.fill;
      
    // Small Orange Accent in middle of bolt
    final Path accentPath = Path();
    accentPath.moveTo(size.width * 0.40, size.height * 0.55);
    accentPath.lineTo(size.width * 0.43, size.height * 0.53);
    accentPath.lineTo(size.width * 0.47, size.height * 0.45);
    accentPath.lineTo(size.width * 0.44, size.height * 0.47);
    accentPath.close();
    
    final Paint accentPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    // Draw the bolt mask and accent
    canvas.drawPath(boltPath, boltPaint);
    canvas.drawPath(accentPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
