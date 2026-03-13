import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class ScorecardScreen extends StatelessWidget {
  const ScorecardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MATCH RESULTS',
          style: GoogleFonts.publicSans(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 80,
              color: AppColors.accent,
            ),
            const SizedBox(height: 24),
            Text(
              'SCORECARD',
              style: GoogleFonts.publicSans(
                color: AppColors.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analysis in progress...',
              style: GoogleFonts.publicSans(
                color: AppColors.secondaryText,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primaryText,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('BACK TO HOME'),
            ),
          ],
        ),
      ),
    );
  }
}
