import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/match_record.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<Box>(
          valueListenable: Hive.box('match_history').listenable(),
          builder: (context, matchBox, _) {
            final matches = matchBox.values.map((m) => MatchRecord.fromMap(m as Map<dynamic, dynamic>)).toList();
            
            final int totalMatches = matches.length;
            final int wins = matches.where((m) => m.result == 'Victory').length;
            final int losses = matches.where((m) => m.result == 'Defeat').length;
            final int draws = matches.where((m) => m.result == 'Draw').length;
            
            int elo = 1000;
            int highestElo = 1000;
            for (var m in matches) {
              elo += m.eloChange;
              if (elo > highestElo) highestElo = elo;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(context),
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
                  const SizedBox(height: 100), // Bottom nav space
                ],
              ),
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
        return Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.surface,
                      child: Icon(Icons.person, size: 50, color: AppColors.secondaryText),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: GoogleFonts.publicSans(
                color: AppColors.primaryText,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Senior Debater',
              style: GoogleFonts.publicSans(
                color: AppColors.secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsGrid(int total, int wins, int losses, int draws, int highest) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatItem('TOTAL MATCHES', total.toString(), Icons.gavel),
        _buildStatItem('WIN RATE', total == 0 ? '0%' : '${((wins / total) * 100).toInt()}%', Icons.emoji_events),
        _buildStatItem('PEAK ELO', highest.toString(), Icons.trending_up),
        _buildStatItem('DRAWS', draws.toString(), Icons.history),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.publicSans(
              color: AppColors.primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.publicSans(
              color: AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.publicSans(
        color: AppColors.secondaryText,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget _buildAchievementsList(int wins) {
    final achievements = [
      {'title': 'Silver Tongue', 'desc': 'Won 1st match', 'unlocked': wins >= 1, 'icon': Icons.mic},
      {'title': 'Unstoppable', 'desc': '5 Match Win Streak', 'unlocked': wins >= 5, 'icon': Icons.bolt},
      {'title': 'Philosopher', 'desc': '10 Matches Completed', 'unlocked': wins >= 10, 'icon': Icons.menu_book},
    ];

    return Column(
      children: achievements.map((ach) {
        bool unlocked = ach['unlocked'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unlocked ? AppColors.surface : AppColors.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unlocked ? AppColors.accent.withOpacity(0.5) : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(
                ach['icon'] as IconData,
                color: unlocked ? AppColors.accent : AppColors.secondaryText,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ach['title'] as String,
                      style: GoogleFonts.publicSans(
                        color: unlocked ? AppColors.primaryText : AppColors.secondaryText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ach['desc'] as String,
                      style: GoogleFonts.publicSans(
                        color: AppColors.secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (unlocked)
                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondaryText, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.publicSans(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: GoogleFonts.publicSans(
                color: AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.secondaryText, size: 16),
        ],
      ),
    );
  }
}
