import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';
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
    _progressController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 5),
    )..forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background subtle glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.05),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: CustomPaint(
                        painter: DLogoPainter(),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'DEBATE',
                      style: GoogleFonts.publicSans(
                        color: AppColors.primaryText,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ME',
                      style: GoogleFonts.publicSans(
                        color: AppColors.accent,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Tagline
                Text(
                  'SHARP MINDS. BOLD ARGUMENTS.',
                  style: GoogleFonts.publicSans(
                    color: AppColors.primaryText.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 80),
                
                // Loading Bar
                SizedBox(
                  width: 240,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'INITIALIZING ENVIRONMENT',
                            style: GoogleFonts.publicSans(
                              color: AppColors.primaryText.withOpacity(0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: AppColors.premiumBlue.withOpacity(0.5),
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              final percent = (_progressController.value * 100).toInt();
                              return Text(
                                '$percent%',
                                style: GoogleFonts.publicSans(
                                  color: AppColors.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 2,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1D23),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return Container(
                                height: 2,
                                width: 240 * _progressController.value,
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.premiumBlue.withOpacity(0.25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Footer
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '• PREMIUM COGNITIVE PLATFORM •',
                style: GoogleFonts.publicSans(
                  color: AppColors.primaryText.withOpacity(0.2),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: AppColors.premiumBlue.withOpacity(0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
