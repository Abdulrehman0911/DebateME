import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/neon_button.dart';
import '../arena/arena_screen.dart';

class PreGameScreen extends StatefulWidget {
  const PreGameScreen({super.key});

  @override
  State<PreGameScreen> createState() => _PreGameScreenState();
}

class _PreGameScreenState extends State<PreGameScreen> {
  final TextEditingController _resolutionController = TextEditingController();
  String _selectedStance = 'PRO';
  String? _selectedOpponent;
  int _selectedRounds = 5;

  final List<Map<String, String>> _opponents = [
    {'name': 'The Philosopher', 'description': 'Deep logic, abstract reasoning, and endless "Why?"', 'icon': '🏛️'},
    {'name': 'The Politician', 'description': 'Master of rhetoric, persuasion, and dodging questions.', 'icon': '🎙️'},
    {'name': 'The Scientist', 'description': 'Empirical, evidence-based, and focused on statistical probability.', 'icon': '🧬'},
    {'name': 'The Aggressor', 'description': 'Direct, blunt, and relentless in dismantling arguments.', 'icon': '⚔️'},
  ];

  @override
  void dispose() { _resolutionController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0,
          title: Text('MATCH SETUP', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1.2))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildSectionTitle('RESOLUTION'),
            const SizedBox(height: 12),
            _buildResolutionInput().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
            
            _buildSectionTitle('ROUNDS'),
            const SizedBox(height: 12),
            _buildRoundsSelector().animate().fadeIn(duration: 400.ms, delay: 50.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
            
            _buildSectionTitle('YOUR STANCE'),
            const SizedBox(height: 12),
            _buildStanceSelector().animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1),
            const SizedBox(height: 32),
            
            _buildSectionTitle('SELECT OPPONENT'),
            const SizedBox(height: 12),
            _buildOpponentSelector(),
            const SizedBox(height: 48),
            
            _buildEnterArenaButton(),
          ]),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 2.0));
  }

  Widget _buildResolutionInput() {
    return TextField(
      controller: _resolutionController,
      style: GoogleFonts.outfit(color: AppColors.primaryText),
      decoration: InputDecoration(
        hintText: 'Enter Custom Resolution', hintStyle: GoogleFonts.outfit(color: AppColors.mutedText.withOpacity(0.5)),
        filled: true, fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.neonPurple, width: 2)),
      ),
    );
  }

  Widget _buildRoundsSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neonPurple.withOpacity(0.5), width: 1.0),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total Rounds: ', style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 14, fontWeight: FontWeight.bold)),
              Text(
                '$_selectedRounds',
                style: GoogleFonts.spaceGrotesk(color: AppColors.electricBlue, fontSize: 32, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.neonPurple,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.electricBlue,
              overlayColor: AppColors.neonPurple.withOpacity(0.2),
              valueIndicatorTextStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
            ),
            child: Slider(
              value: _selectedRounds.toDouble(),
              min: 4,
              max: 15,
              divisions: 11,
              label: _selectedRounds.toString(),
              onChanged: (value) {
                setState(() {
                  _selectedRounds = value.toInt();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStanceSelector() {
    return Row(children: [
      Expanded(child: _buildStanceButton('PRO', AppColors.neonPurple)),
      const SizedBox(width: 16),
      Expanded(child: _buildStanceButton('CON', AppColors.electricBlue)),
    ]);
  }

  Widget _buildStanceButton(String stance, Color color) {
    bool isSelected = _selectedStance == stance;
    return GestureDetector(
      onTap: () => setState(() => _selectedStance = stance),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), height: 60,
        decoration: BoxDecoration(
          gradient: isSelected ? LinearGradient(colors: [color, color.withOpacity(0.7)]) : null,
          color: isSelected ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : AppColors.divider, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 4))] : [],
        ),
        alignment: Alignment.center,
        child: Text(stance, style: GoogleFonts.spaceGrotesk(color: isSelected ? Colors.white : AppColors.mutedText, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildOpponentSelector() {
    return Column(children: _opponents.asMap().entries.map((entry) {
      final idx = entry.key;
      final opponent = entry.value;
      bool isSelected = _selectedOpponent == opponent['name'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: GestureDetector(
          onTap: () => setState(() => _selectedOpponent = opponent['name']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.neonPurple.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? AppColors.neonPurple : AppColors.divider, width: isSelected ? 2 : 1),
              boxShadow: isSelected ? [BoxShadow(color: AppColors.neonPurple.withOpacity(0.15), blurRadius: 16)] : [],
            ),
            child: Row(children: [
              Text(opponent['icon']!, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(opponent['name']!, style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(opponent['description']!, style: GoogleFonts.outfit(color: AppColors.mutedText, fontSize: 12)),
              ])),
              if (isSelected) ShaderMask(shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds), child: const Icon(Icons.check_circle, color: Colors.white)),
            ]),
          ),
        ),
      ).animate().fadeIn(duration: 400.ms, delay: (150 * idx).ms).slideX(begin: 0.1);
    }).toList());
  }

  Widget _buildEnterArenaButton() {
    bool canProceed = _selectedOpponent != null;
    if (!canProceed) {
      return SizedBox(width: double.infinity, height: 64, child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.divider, disabledBackgroundColor: AppColors.divider, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Text('ENTER ARENA', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, color: AppColors.mutedText)),
      ));
    }
    return NeonButton(text: 'ENTER ARENA', icon: Icons.flash_on, height: 64, onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ArenaScreen(
        topic: _resolutionController.text.isEmpty ? 'Centralization vs. Decentralization' : _resolutionController.text,
        userStance: _selectedStance == 'PRO' ? 'Pro-${_resolutionController.text.isEmpty ? 'Decentralization' : _resolutionController.text}' : 'Anti-${_resolutionController.text.isEmpty ? 'Decentralization' : _resolutionController.text}',
        opponentPersona: _selectedOpponent!,
        totalRounds: _selectedRounds,
      )));
    });
  }
}
