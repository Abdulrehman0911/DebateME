import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/match_record.dart';
import '../../widgets/glass_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 24),
            Text('History', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
            const SizedBox(height: 8),
            Text('Relive your past debates', style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 16)),
            const SizedBox(height: 32),
            Expanded(child: ValueListenableBuilder<Box>(
              valueListenable: Hive.box('match_history').listenable(),
              builder: (context, box, _) {
                final matches = box.values.toList().reversed.toList();
                if (matches.isEmpty) {
                  return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.history, size: 64, color: AppColors.mutedText.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No matches yet.', style: GoogleFonts.outfit(color: AppColors.mutedText)),
                  ]));
                }
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100), itemCount: matches.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = MatchRecord.fromMap(matches[index] as Map<dynamic, dynamic>);
                    final delayMs = (50 * index).clamp(0, 500);
                    return _buildHistoryTile(record).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delayMs)).slideX(begin: 0.05);
                  },
                );
              },
            )),
          ]),
        ),
      ),
    );
  }

  Widget _buildHistoryTile(MatchRecord record) {
    final color = record.result == 'Victory' ? AppColors.victory : (record.result == 'Draw' ? AppColors.draw : AppColors.defeat);
    final icon = record.result == 'Victory' ? Icons.emoji_events : (record.result == 'Draw' ? Icons.history : Icons.close);
    final timeAgo = _getTimeAgo(record.date);
    return GlassCard(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 22)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${record.result} vs ${record.opponentPersona}', style: GoogleFonts.outfit(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${record.topic} • $timeAgo', style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 11)),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('${record.result == 'Victory' ? "+" : (record.result == 'Defeat' ? "-" : "")}${record.eloChange}', style: GoogleFonts.spaceGrotesk(color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        Text('ELO', style: GoogleFonts.outfit(color: AppColors.mutedText.withOpacity(0.5), fontSize: 10, fontWeight: FontWeight.bold)),
      ]),
    ]));
  }

  String _getTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
