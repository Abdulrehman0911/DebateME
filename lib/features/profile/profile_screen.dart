import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: AppColors.deepVoid,
        body: Center(child: Text('Not logged in', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.neonPurple),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error loading profile', style: TextStyle(color: AppColors.defeat)),
                );
              }

              final data = (snapshot.hasData && snapshot.data!.exists) ? snapshot.data!.data() as Map<String, dynamic>? : null;
              final String username = data?['username'] ?? currentUser.displayName ?? 'Debater';
              final String email = data?['email'] ?? currentUser.email ?? 'Unknown Email';
              final int elo = data?['elo'] ?? 1000;
              final int wins = data?['wins'] ?? 0;
              final int losses = data?['losses'] ?? 0;
              final int streak = data?['streak'] ?? 0;
              final int totalMatches = data?['totalMatches'] ?? (wins + losses);
              final double winRate = totalMatches > 0 ? (wins / totalMatches) * 100 : 0.0;

              return Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Top: Glowing Avatar ---
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonPurple.withOpacity(0.3),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: GlassCard(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 100,
                        borderColor: AppColors.electricBlue.withOpacity(0.3),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.transparent,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 24),

                    // --- Middle: Username & Email ---
                    Text(
                      username,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 8),

                    Text(
                      email,
                      style: GoogleFonts.outfit(
                        color: AppColors.mutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 48),

                    // --- Stats Grid ---
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        _buildStatCard('ELO RATING', elo.toString(), Icons.emoji_events, AppColors.neonPurple, 0),
                        _buildStatCard('WINNING STREAK', streak.toString(), Icons.local_fire_department, AppColors.draw, 1),
                        _buildStatCard('WINS', wins.toString(), Icons.check_circle_outline, AppColors.victory, 2),
                        _buildStatCard('LOSSES', losses.toString(), Icons.cancel_outlined, AppColors.defeat, 3),
                        _buildStatCard('TOTAL MATCHES', totalMatches.toString(), Icons.tag, AppColors.electricBlue, 4),
                        _buildStatCard('WIN RATE', '${winRate.toStringAsFixed(1)}%', Icons.pie_chart_outline, AppColors.accentGradient.colors.first, 5),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // --- Bottom: Log Out Button ---
                    NeonButton(
                      text: 'LOG OUT',
                      icon: Icons.logout_rounded,
                      gradientColors: const [AppColors.defeat, Color(0xFF880000)],
                      height: 60,
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted && Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    ).animate().fadeIn(duration: 500.ms, delay: 400.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
            ],
          );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor, int idx) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: Colors.white.withOpacity(0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: AppColors.mutedText,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: (100 * idx).ms).slideY(begin: 0.1);
  }
}
