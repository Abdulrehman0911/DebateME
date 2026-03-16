import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

import '../../core/models/match_record.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ScorecardScreen extends StatefulWidget {
  final Map<String, dynamic> evaluationData;

  const ScorecardScreen({
    super.key,
    required this.evaluationData,
  });

  @override
  State<ScorecardScreen> createState() => _ScorecardScreenState();
}

class _ScorecardScreenState extends State<ScorecardScreen> {
  bool _recordSaved = false;

  @override
  void initState() {
    super.initState();
    _saveMatch();
  }

  Future<void> _saveMatch() async {
    if (widget.evaluationData.isEmpty || _recordSaved) return;

    final clarity = widget.evaluationData['clarityScore'] ?? 0;
    final logic = widget.evaluationData['logicScore'] ?? 0;
    final rebuttal = widget.evaluationData['rebuttalScore'] ?? 0;
    final fallacyScore = widget.evaluationData['fallacyScore'] ?? 0;

    final double finalScore = ((clarity + logic + rebuttal) / 3) - (fallacyScore * 0.5);
    final bool hasWon = finalScore >= 65;

    final record = MatchRecord(
      topic: widget.evaluationData['topic'] ?? 'Custom Match',
      userStance: widget.evaluationData['userStance'] ?? 'User Stance',
      opponentPersona: widget.evaluationData['opponentPersona'] ?? 'AI Debater',
      isVictory: hasWon,
      date: DateTime.now(),
    );

    final box = Hive.box('match_history');
    await box.add(record.toMap());
    
    if (mounted) {
      setState(() {
        _recordSaved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.evaluationData.isEmpty) {
      return _buildForfeitState(context);
    }

    // New Win/Loss Formula: ((clarity + logic + rebuttals) / 3) - (fallacies * 0.5)
    final clarity = (widget.evaluationData['clarityScore'] ?? 0);
    final logic = (widget.evaluationData['logicScore'] ?? 0);
    final rebuttal = (widget.evaluationData['rebuttalScore'] ?? 0);
    final fallacyScore = (widget.evaluationData['fallacyScore'] ?? 0);

    final double finalScore = ((clarity + logic + rebuttal) / 3) - (fallacyScore * 0.5);
    final bool hasWon = finalScore >= 65;

    final clarityRatio = clarity / 100.0;
    final logicRatio = logic / 100.0;
    final rebuttalRatio = rebuttal / 100.0;
    final fallaciesRatio = fallacyScore / 100.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.secondaryText),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              hasWon ? 'YOU WON' : 'DEFEAT',
              style: GoogleFonts.publicSans(
                color: hasWon ? AppColors.accent : Colors.redAccent,
                fontSize: 64,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 0.9,
              ),
            ),
            const SizedBox(height: 48),
            _buildPerformanceScorecard(clarityRatio, logicRatio, rebuttalRatio, fallaciesRatio),
            const SizedBox(height: 32),
            _buildHighlightBlock(widget.evaluationData['bestArgumentHighlight'] ?? 'No highlight available.'),
            const SizedBox(height: 32),
            _buildCoachButton(context),
            const SizedBox(height: 16),
            _buildShareButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCoachButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () => _showCoachAnalysisModal(context),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          foregroundColor: AppColors.primaryText,
        ),
        child: Text(
          '🤖 VIEW COACH ANALYSIS',
          style: GoogleFonts.publicSans(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  void _showCoachAnalysisModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics_outlined, color: AppColors.accent, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Coach Feedback',
                    style: GoogleFonts.publicSans(
                      color: AppColors.primaryText,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Text(
                  'Logic Integrity Sub-score: ${widget.evaluationData['fallacyScore']}%',
                  style: GoogleFonts.publicSans(
                    color: Colors.redAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.evaluationData['coachFeedback'] ?? 'Keep practicing to improve your debating skills!',
                style: GoogleFonts.publicSans(
                  color: AppColors.secondaryText,
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'CLOSE',
                    style: GoogleFonts.publicSans(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceScorecard(double clarity, double logic, double rebuttal, double fallacies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE SCORECARD',
          style: GoogleFonts.publicSans(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 24),
        _buildStatRow('Clarity', clarity),
        _buildStatRow('Logic', logic),
        _buildStatRow('Rebuttals', rebuttal),
        _buildStatRow('Fallacies (Detected)', fallacies, isInverse: true),
      ],
    );
  }

  Widget _buildStatRow(String label, double value, {bool isInverse = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.publicSans(
                  color: AppColors.primaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${(value * 100).toInt().toString().padLeft(2, '0')}%',
                style: GoogleFonts.publicSans(
                  color: isInverse ? Colors.redAccent : AppColors.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(
                isInverse ? Colors.redAccent : AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBlock(String highlight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BEST ARGUMENT HIGHLIGHT',
            style: GoogleFonts.publicSans(
              color: AppColors.secondaryText,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"$highlight"',
            style: GoogleFonts.publicSans(
              color: AppColors.primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () async {
          final clarity = widget.evaluationData['clarityScore'] ?? 0;
          final logic = widget.evaluationData['logicScore'] ?? 0;
          final rebuttal = widget.evaluationData['rebuttalScore'] ?? 0;
          final fallacyScore = widget.evaluationData['fallacyScore'] ?? 0;
          
          final double finalScore = ((clarity + logic + rebuttal) / 3) - (fallacyScore * 0.5);
          final bool isVictory = finalScore >= 65;

          final shareText = '🏛️ DEBATEME RESULTS\n\n'
              'Status: ${isVictory ? "Victory" : "Defeat"}\n'
              'Clarity: $clarity%\n'
              'Logic: $logic%\n'
              'Rebuttals: $rebuttal%\n'
              'Fallacies: $fallacyScore%\n\n'
              'Coach Feedback: ${widget.evaluationData['coachFeedback']}\n\n'
              'Play at DebateMe!';

          await Clipboard.setData(ClipboardData(text: shareText));

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Results copied to clipboard!'),
                backgroundColor: AppColors.accent,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppColors.accent.withOpacity(0.5),
        ),
        child: Text(
          'SHARE RESULTS',
          style: GoogleFonts.publicSans(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildForfeitState(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.secondaryText),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flag_outlined, size: 80, color: AppColors.secondaryText),
            const SizedBox(height: 24),
            Text(
              'MATCH FORFEITED',
              style: GoogleFonts.publicSans(
                color: AppColors.primaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No scores were calculated.',
              style: GoogleFonts.publicSans(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
