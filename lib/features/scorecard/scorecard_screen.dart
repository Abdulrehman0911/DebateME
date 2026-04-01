import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/match_record.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_text.dart';
import '../../widgets/neon_button.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScorecardScreen extends StatefulWidget {
  final Map<String, dynamic> evaluationData;
  const ScorecardScreen({super.key, required this.evaluationData});

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> with SingleTickerProviderStateMixin {
  bool _recordSaved = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..forward();
    _saveMatch();
  }

  @override
  void dispose() { _animController.dispose(); super.dispose(); }

  Future<void> _saveMatch() async {
    if (widget.evaluationData.isEmpty || _recordSaved) return;
    final clarity = widget.evaluationData['clarityScore'] ?? 0;
    final logic = widget.evaluationData['logicScore'] ?? 0;
    final rebuttal = widget.evaluationData['rebuttalScore'] ?? 0;
    final fallacyScore = widget.evaluationData['fallacyScore'] ?? 0;
    final double finalScore = ((clarity + logic + rebuttal) / 3) - (fallacyScore * 0.5);
    String result; int eloChange;
    if (finalScore >= 65) { result = 'Victory'; eloChange = 24; }
    else if (finalScore >= 50) { result = 'Draw'; eloChange = 0; }
    else { result = 'Defeat'; eloChange = -15; }
    final record = MatchRecord(topic: widget.evaluationData['topic'] ?? 'Custom Match', userStance: widget.evaluationData['userStance'] ?? 'User Stance', opponentPersona: widget.evaluationData['opponentPersona'] ?? 'AI Debater', result: result, date: DateTime.now(), eloChange: eloChange);
    final box = Hive.box('match_history');
    await box.add(record.toMap());

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(docRef);
          if (snapshot.exists) {
            final data = snapshot.data() as Map<String, dynamic>;
            int currentElo = data['elo'] ?? 1000;
            int currentStreak = data['streak'] ?? 0;
            
            int newStreak = result == 'Victory' ? currentStreak + 1 : (result == 'Defeat' ? 0 : currentStreak);
            
            transaction.update(docRef, {
              'elo': currentElo + eloChange,
              'streak': newStreak,
              'totalMatches': FieldValue.increment(1),
              if (result == 'Victory') 'wins': FieldValue.increment(1),
              if (result == 'Defeat') 'losses': FieldValue.increment(1),
            });
          }
        });
      } catch (e) {
        // Silently handle error to not break the UI, though it should be logged in a real app
      }
    }

    if (mounted) setState(() => _recordSaved = true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.evaluationData.isEmpty) return _buildForfeitState(context);
    final clarity = (widget.evaluationData['clarityScore'] ?? 0);
    final logic = (widget.evaluationData['logicScore'] ?? 0);
    final rebuttal = (widget.evaluationData['rebuttalScore'] ?? 0);
    final fallacyScore = (widget.evaluationData['fallacyScore'] ?? 0);
    final double finalScore = ((clarity + logic + rebuttal) / 3) - (fallacyScore * 0.5);
    String status; Color glowColor;
    if (finalScore >= 65) { status = 'VICTORY'; glowColor = AppColors.victory; }
    else if (finalScore >= 50) { status = 'DRAW'; glowColor = AppColors.draw; }
    else { status = 'DEFEAT'; glowColor = AppColors.defeat; }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: AppColors.mutedText), onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 20),
            NeonText(text: status, fontSize: 56, glowColor: glowColor, glowIntensity: 16).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 600.ms),
            const SizedBox(height: 48),
            _buildPerformanceScorecard(clarity / 100.0, logic / 100.0, rebuttal / 100.0, fallacyScore / 100.0),
            const SizedBox(height: 32),
            _buildHighlightBlock(widget.evaluationData['bestArgumentHighlight'] ?? 'No highlight available.'),
            const SizedBox(height: 32),
            _buildCoachButton(context),
            const SizedBox(height: 16),
            _buildShareButton(context),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  Widget _buildCoachButton(BuildContext context) {
    return SizedBox(width: double.infinity, height: 56, child: OutlinedButton(
      onPressed: () => _showCoachAnalysisModal(context),
      style: OutlinedButton.styleFrom(side: BorderSide(color: AppColors.electricBlue.withOpacity(0.5), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), foregroundColor: AppColors.primaryText),
      child: Text('🤖 VIEW COACH ANALYSIS', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1.2)),
    )).animate().fadeIn(duration: 500.ms, delay: 800.ms).slideY(begin: 0.2);
  }

  void _showCoachAnalysisModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                      child: const Icon(Icons.psychology_outlined, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'AI Coach Feedback',
                      style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildAnalysisSection('🚩 LOGICAL FALLACIES', widget.evaluationData['logicalFallaciesCommitted'] ?? 'None detected.'),
                const SizedBox(height: 20),
                _buildAnalysisSection('🎯 STRATEGIC MISTAKES', widget.evaluationData['strategicMistakes'] ?? 'Overall solid performance.'),
                const SizedBox(height: 20),
                _buildAnalysisSection('🚀 HOW TO IMPROVE', widget.evaluationData['howToImprove'] ?? 'Keep practicing your rebuttals.'),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.deepVoid,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'GOT IT',
                      style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(color: AppColors.electricBlue, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            content,
            style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 15, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceScorecard(double clarity, double logic, double rebuttal, double fallacies) {
    return GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('PERFORMANCE SCORECARD', style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2)),
      const SizedBox(height: 24),
      _buildAnimatedStatRow('Clarity', clarity, 0),
      _buildAnimatedStatRow('Logic', logic, 1),
      _buildAnimatedStatRow('Rebuttals', rebuttal, 2),
      _buildAnimatedStatRow('Fallacies (Detected)', fallacies, 3, isInverse: true),
    ])).animate().fadeIn(duration: 500.ms, delay: 300.ms).slideY(begin: 0.15);
  }

  Widget _buildAnimatedStatRow(String label, double value, int index, {bool isInverse = false}) {
    return Padding(padding: const EdgeInsets.only(bottom: 24.0), child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.outfit(color: AppColors.primaryText, fontSize: 14, fontWeight: FontWeight.w600)),
        AnimatedBuilder(animation: _animController, builder: (context, child) {
          final animVal = (_animController.value * value * 100).toInt();
          return Text('${animVal.toString().padLeft(2, '0')}%', style: GoogleFonts.spaceGrotesk(color: isInverse ? AppColors.defeat : AppColors.neonPurple, fontSize: 14, fontWeight: FontWeight.w900));
        }),
      ]),
      const SizedBox(height: 8),
      AnimatedBuilder(animation: _animController, builder: (context, child) {
        return ClipRRect(borderRadius: BorderRadius.circular(4), child: Stack(children: [
          Container(height: 6, width: double.infinity, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(4))),
          FractionallySizedBox(widthFactor: _animController.value * value, child: Container(height: 6, decoration: BoxDecoration(
            gradient: isInverse ? const LinearGradient(colors: [AppColors.defeat, Color(0xFFFF6699)]) : AppColors.accentGradient,
            borderRadius: BorderRadius.circular(4),
            boxShadow: [BoxShadow(color: (isInverse ? AppColors.defeat : AppColors.neonPurple).withOpacity(0.5), blurRadius: 8)],
          ))),
        ]));
      }),
    ]));
  }

  Widget _buildHighlightBlock(String highlight) {
    return GlassCard(
      borderColor: AppColors.electricBlue.withOpacity(0.2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('BEST ARGUMENT HIGHLIGHT', style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Text('"$highlight"', style: GoogleFonts.outfit(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, height: 1.4)),
      ]),
    ).animate().fadeIn(duration: 500.ms, delay: 600.ms).slideY(begin: 0.15);
  }

  Widget _buildShareButton(BuildContext context) {
    return NeonButton(text: 'SHARE RESULTS', icon: Icons.share_rounded, onPressed: () async {
      final clarity = widget.evaluationData['clarityScore'] ?? 0;
      final logic = widget.evaluationData['logicScore'] ?? 0;
      final rebuttal = widget.evaluationData['rebuttalScore'] ?? 0;
      final fallacyScore = widget.evaluationData['fallacyScore'] ?? 0;
      final double finalScore = ((clarity + logic + rebuttal) / 3) - (fallacyScore * 0.5);
      String status;
      if (finalScore >= 65) { status = 'Victory'; } else if (finalScore >= 50) { status = 'Draw'; } else { status = 'Defeat'; }
      final shareText = '🏛️ DEBATEME RESULTS\n\nStatus: $status\nClarity: $clarity%\nLogic: $logic%\nRebuttals: $rebuttal%\nFallacies: $fallacyScore%\n\nCoach: ${widget.evaluationData['coachFeedback']}\n\nPlay at DebateMe!';
      await Clipboard.setData(ClipboardData(text: shareText));
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Results copied to clipboard!'), backgroundColor: AppColors.neonPurple));
    });
  }

  Widget _buildForfeitState(BuildContext context) {
    return Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient), child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.close, color: AppColors.mutedText), onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst))),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.flag_outlined, size: 80, color: AppColors.mutedText),
        const SizedBox(height: 24),
        NeonText(text: 'FORFEITED', fontSize: 36, glowColor: AppColors.defeat),
        const SizedBox(height: 8),
        Text('No scores were calculated.', style: GoogleFonts.outfit(color: AppColors.mutedText)),
      ])),
    ));
  }
}
