import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/match_record.dart';

class LeaguesScreen extends StatelessWidget {
  const LeaguesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ValueListenableBuilder<Box>(
          valueListenable: Hive.box('match_history').listenable(),
          builder: (context, box, _) {
            final matches = box.values.map((m) => MatchRecord.fromMap(m as Map<dynamic, dynamic>)).toList();
            int userElo = 1000;
            for (var m in matches) {
              userElo += m.eloChange;
            }

            final List<Map<String, dynamic>> leaderboard = [
              {'name': 'Hyperion AI', 'elo': 2840, 'rank': 1, 'isUser': false},
              {'name': 'LogicGate', 'elo': 2615, 'rank': 2, 'isUser': false},
              {'name': 'Sophia-7', 'elo': 2490, 'rank': 3, 'isUser': false},
              {'name': 'Marcus Aurelius', 'elo': 2300, 'rank': 4, 'isUser': false},
              {'name': 'The Oracle', 'elo': 2150, 'rank': 5, 'isUser': false},
              {'name': 'YOU', 'elo': userElo, 'rank': 142, 'isUser': true},
              {'name': 'ByteWise', 'elo': 1980, 'rank': 6, 'isUser': false},
              {'name': 'Nebula', 'elo': 1850, 'rank': 7, 'isUser': false},
            ];

            // Sort by ELO for the mockup feel, but keep YOU at its rank
            leaderboard.sort((a, b) => b['elo'].compareTo(a['elo']));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Global Leagues',
                        style: GoogleFonts.publicSans(
                          color: AppColors.primaryText,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Top Debaters in the World',
                        style: GoogleFonts.publicSans(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildLeagueHeader(),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      final item = leaderboard[index];
                      return _buildLeaderboardTile(item, index);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeagueHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accent.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MASTER LEAGUE',
                style: GoogleFonts.publicSans(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Top 2%',
                style: GoogleFonts.publicSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Icon(Icons.shield, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(Map<String, dynamic> item, int index) {
    bool isUser = item['isUser'];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isUser ? AppColors.accent.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUser ? AppColors.accent : AppColors.divider.withOpacity(0.5),
          width: isUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '#${item['rank']}',
              style: GoogleFonts.publicSans(
                color: isUser ? AppColors.accent : AppColors.secondaryText,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.background,
            child: Icon(
              isUser ? Icons.person : Icons.psychology,
              size: 18,
              color: isUser ? AppColors.accent : AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item['name'],
              style: GoogleFonts.publicSans(
                color: AppColors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['elo'].toString(),
                style: GoogleFonts.publicSans(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                'ELO',
                style: GoogleFonts.publicSans(
                  color: AppColors.secondaryText.withOpacity(0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
