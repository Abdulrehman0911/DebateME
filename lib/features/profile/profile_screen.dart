import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/match_record.dart';
import '../../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: ValueListenableBuilder<Box>(
          valueListenable: Hive.box('match_history').listenable(),
          builder: (context, matchBox, _) {
            final matches = matchBox.values.map((m) => MatchRecord.fromMap(m as Map<dynamic, dynamic>)).toList();
            final int totalMatches = matches.length;
            final int wins = matches.where((m) => m.result == 'Victory').length;
            final int losses = matches.where((m) => m.result == 'Defeat').length;
            final int draws = matches.where((m) => m.result == 'Draw').length;
            int elo = 1000; int highestElo = 1000;
            for (var m in matches) { elo += m.eloChange; if (elo > highestElo) highestElo = elo; }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildProfileHeader(context).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 32),
                _buildStatsGrid(totalMatches, wins, losses, draws, highestElo),
                const SizedBox(height: 32),
                _buildSectionTitle('ACHIEVEMENTS'),
                const SizedBox(height: 16),
                _buildAchievementsList(wins),
                const SizedBox(height: 32),
                _buildSectionTitle('ACCOUNT SETTINGS'),
                const SizedBox(height: 16),
                _buildSettingsTile(Icons.notifications_outlined, 'Notifications', 'Enabled'),
                _buildSettingsTile(Icons.lock_outline, 'Privacy', 'Public'),
                _buildSettingsTile(Icons.help_outline, 'Help & Support', ''),
                const SizedBox(height: 100),
              ]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return ValueListenableBuilder<Box>(
      valueListenable: Hive.box('user_settings').listenable(keys: ['username']),
      builder: (context, box, _) {
        final String name = box.get('username', defaultValue: 'Abdulrehman');
        return Column(children: [
          Center(child: Stack(children: [
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppColors.accentGradient),
              child: CircleAvatar(radius: 50, backgroundColor: AppColors.surface, child: Icon(Icons.person, size: 50, color: AppColors.mutedText))),
            Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(gradient: AppColors.accentGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.5), blurRadius: 8)]),
              child: const Icon(Icons.edit, color: Colors.white, size: 16))),
          ])),
          const SizedBox(height: 16),
          Text(name, style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          ShaderMask(shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
            child: Text('Senior Debater', style: GoogleFonts.outfit(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
        ]);
      },
    );
  }

  Widget _buildStatsGrid(int total, int wins, int losses, int draws, int highest) {
    return GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.5, children: [
      _buildStatItem('TOTAL MATCHES', total.toString(), Icons.gavel, 0),
      _buildStatItem('WIN RATE', total == 0 ? '0%' : '${((wins / total) * 100).toInt()}%', Icons.emoji_events, 1),
      _buildStatItem('PEAK ELO', highest.toString(), Icons.trending_up, 2),
      _buildStatItem('DRAWS', draws.toString(), Icons.history, 3),
    ]);
  }

  Widget _buildStatItem(String label, String value, IconData icon, int idx) {
    return GlassCard(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      ShaderMask(shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds), child: Icon(icon, color: Colors.white, size: 20)),
      const SizedBox(height: 8),
      Text(value, style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontSize: 20, fontWeight: FontWeight.w900)),
      Text(label, style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 10, fontWeight: FontWeight.bold)),
    ])).animate().fadeIn(duration: 400.ms, delay: (100 * idx).ms).slideY(begin: 0.1);
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2));
  }

  Widget _buildAchievementsList(int wins) {
    final achievements = [
      {'title': 'Silver Tongue', 'desc': 'Won 1st match', 'unlocked': wins >= 1, 'icon': Icons.mic},
      {'title': 'Unstoppable', 'desc': '5 Match Win Streak', 'unlocked': wins >= 5, 'icon': Icons.bolt},
      {'title': 'Philosopher', 'desc': '10 Matches Completed', 'unlocked': wins >= 10, 'icon': Icons.menu_book},
    ];
    return Column(children: achievements.asMap().entries.map((entry) {
      final idx = entry.key; final ach = entry.value;
      bool unlocked = ach['unlocked'] as bool;
      return Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked ? AppColors.neonPurple.withOpacity(0.08) : const Color(0xFF171721).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: unlocked ? AppColors.neonPurple.withOpacity(0.4) : AppColors.divider),
          boxShadow: unlocked ? [BoxShadow(color: AppColors.neonPurple.withOpacity(0.1), blurRadius: 12)] : [],
        ),
        child: Row(children: [
          Icon(ach['icon'] as IconData, color: unlocked ? AppColors.neonPurple : AppColors.mutedText),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ach['title'] as String, style: GoogleFonts.outfit(color: unlocked ? AppColors.primaryText : AppColors.mutedText, fontWeight: FontWeight.bold)),
            Text(ach['desc'] as String, style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 12)),
          ])),
          if (unlocked) const Icon(Icons.check_circle, color: AppColors.victory, size: 16),
        ]),
      ).animate().fadeIn(duration: 400.ms, delay: (100 * idx).ms).slideX(begin: 0.05);
    }).toList());
  }

  Widget _buildSettingsTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider.withOpacity(0.5)))),
      child: Row(children: [
        Icon(icon, color: AppColors.mutedText, size: 20), const SizedBox(width: 16),
        Expanded(child: Text(title, style: GoogleFonts.outfit(color: AppColors.primaryText, fontWeight: FontWeight.w600))),
        if (value.isNotEmpty) Text(value, style: GoogleFonts.outfit(color: AppColors.mutedText, fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: AppColors.mutedText, size: 16),
      ]),
    );
  }
}
