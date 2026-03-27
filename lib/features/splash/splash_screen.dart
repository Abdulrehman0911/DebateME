import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../auth/login_screen.dart';
import 'widgets/d_logo_painter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    });
  }

  @override
  void dispose() { _progressController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          // Neon glow orbs
          Positioned(top: -100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neonPurple.withOpacity(0.06)))),
          Positioned(bottom: -80, right: -80, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.electricBlue.withOpacity(0.04)))),
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Logo Container
            Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.neonPurple.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.15), blurRadius: 40, spreadRadius: -5), BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 10))],
              ),
              child: Center(child: SizedBox(width: 100, height: 100, child: CustomPaint(painter: DLogoPainter()))),
            ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 800.ms, curve: Curves.easeOut),
            const SizedBox(height: 48),
            // Title
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('DEBATE', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontSize: 36, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -1)),
              const SizedBox(width: 8),
              ShaderMask(shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                child: Text('ME', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -1))),
            ]).animate().fadeIn(duration: 600.ms, delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(height: 8),
            Text('SHARP MINDS. BOLD ARGUMENTS.', style: GoogleFonts.outfit(color: AppColors.mutedText.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 2)).animate().fadeIn(duration: 600.ms, delay: 500.ms),
            const SizedBox(height: 80),
            // Loading Bar
            SizedBox(width: 240, child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('INITIALIZING ENVIRONMENT', style: GoogleFonts.outfit(color: AppColors.mutedText.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                AnimatedBuilder(animation: _progressController, builder: (context, child) {
                  return Text('${(_progressController.value * 100).toInt()}%', style: GoogleFonts.spaceGrotesk(color: AppColors.neonPurple, fontSize: 10, fontWeight: FontWeight.bold));
                }),
              ]),
              const SizedBox(height: 12),
              Stack(children: [
                Container(height: 2, width: double.infinity, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(1))),
                AnimatedBuilder(animation: _progressController, builder: (context, child) {
                  return Container(height: 2, width: 240 * _progressController.value, decoration: BoxDecoration(
                    gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(1),
                    boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.5), blurRadius: 12)],
                  ));
                }),
              ]),
            ])).animate().fadeIn(duration: 600.ms, delay: 700.ms),
          ])),
          // Footer
          Positioned(bottom: 40, left: 0, right: 0, child: Center(child: ShaderMask(
            shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
            child: Text('• PREMIUM COGNITIVE PLATFORM •', style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 2)),
          ))).animate().fadeIn(duration: 600.ms, delay: 900.ms),
        ]),
      ),
    );
  }
}
