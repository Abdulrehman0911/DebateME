import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../services/ai_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/neon_button.dart';
import '../scorecard/scorecard_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArenaScreen extends StatefulWidget {
  final String topic;
  final String userStance;
  final String opponentPersona;
  final int totalRounds;

  const ArenaScreen({
    super.key,
    required this.topic,
    required this.userStance,
    required this.opponentPersona,
    required this.totalRounds,
  });

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIDebateService _aiService = AIDebateService();
  late final List<Map<String, dynamic>> _messages;
  bool _isTyping = false;
  int _userMessageCount = 0;
  bool _isMatchOver = false;
  bool _isAnalyzing = false;
  late final List<int> _steelManRounds;
  final Set<int> _completedSteelMans = {};
  int _userElo = 1000;

  @override
  void initState() {
    super.initState();
    _messages = [
      if (widget.userStance.toLowerCase().contains('pro'))
        {
          'isAI': true,
          'text': 'I am the ${widget.opponentPersona}. You are defending the PRO stance on ${widget.topic}. Make your opening argument.',
        },
    ];
    _steelManRounds = _calculateSteelManRounds(widget.totalRounds);
    _fetchUserElo();
    if (widget.userStance.toLowerCase().contains('anti') || widget.userStance.toLowerCase().contains('con')) {
      _startAiDebate();
    }
  }

  Future<void> _fetchUserElo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted && doc.exists) {
        setState(() { _userElo = doc.data()?['elo'] ?? 1000; });
      }
    }
  }

  List<int> _calculateSteelManRounds(int total) {
    if (total <= 7) return [total ~/ 2 + 1];
    if (total <= 12) return [(total / 3).floor() + 1, (2 * total / 3).floor() + 1];
    return [(total / 4).floor() + 1, (2 * total / 4).floor() + 1, (3 * total / 4).floor() + 1];
  }

  Future<void> _startAiDebate() async {
    setState(() => _isTyping = true);
    try {
      final chatHistory = _messages.map((m) => m['isAI'] == true 
        ? Content.model([TextPart(m['text'] as String)]) 
        : Content.text(m['text'] as String)).toList();

      final response = await _aiService.getResponse(
        '[AI starts: Make your opening argument for the PRO side.]',
        widget.topic,
        widget.opponentPersona,
        _userElo,
        chatHistory,
        _userMessageCount,
        widget.totalRounds,
      );
      if (mounted) {
        setState(() { _isTyping = false; _messages.add({'isAI': true, 'text': response}); });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isTyping = false; _messages.add({'isAI': true, 'text': 'Error: Failed to connect to the AI.'}); });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    // Check for Steel-Man Round
    int currentRound = _userMessageCount + 1;
    if (_steelManRounds.contains(currentRound) && !_completedSteelMans.contains(currentRound)) {
      _showSteelManModal(currentRound, text);
      return;
    }

    _processSendMessage(text);
  }

  Future<void> _processSendMessage(String text, {String? steelManText}) async {
    setState(() { 
      String finalMsg = steelManText != null 
          ? "[STEEL-MAN]: $steelManText\n\n[ARGUMENT]: $text" 
          : text;
      _messages.add({'isAI': false, 'text': finalMsg}); 
      _messageController.clear(); 
      _isTyping = true; 
      _userMessageCount++; 
    });
    _scrollToBottom();
    try {
      final chatHistory = _messages.sublist(0, _messages.length - 1).map((m) => m['isAI'] == true 
        ? Content.model([TextPart(m['text'] as String)]) 
        : Content.text(m['text'] as String)).toList();

      final response = await _aiService.getResponse(
        _messages.last['text'] as String,
        widget.topic,
        widget.opponentPersona,
        _userElo, // Real-time Elo from Firestore
        chatHistory,
        _userMessageCount,
        widget.totalRounds,
      );
      if (mounted) {
        setState(() { _isTyping = false; _messages.add({'isAI': true, 'text': response}); if (_userMessageCount >= widget.totalRounds) _isMatchOver = true; });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('AI ERROR: $e'); // Log actual error for debugging
      if (mounted) {
        setState(() { _isTyping = false; _messages.add({'isAI': true, 'text': 'Error: Failed to connect (Check connection or API key).'}); });
        _scrollToBottom();
      }
    }
  }

  void _showSteelManModal(int round, String originalText) {
    final TextEditingController steelManController = TextEditingController();
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Steel-Man Modal',
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10 * anim1.value, sigmaY: 10 * anim1.value),
          child: FadeTransition(
            opacity: anim1,
            child: ScaleTransition(
              scale: anim1.drive(CurveTween(curve: Curves.easeOutBack)),
              child: AlertDialog(
                backgroundColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                content: GlassCard(
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  borderColor: AppColors.electricBlue.withOpacity(0.5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds),
                        child: Text(
                          '⚡ STEEL-MAN ROUND!',
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Pause the debate. Summarize your opponent's last argument fairly and strongly. A good steel-man boosts your final score!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: AppColors.mutedText,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: steelManController,
                        maxLines: 3,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Summarize their argument...',
                          hintStyle: GoogleFonts.outfit(color: Colors.white24),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      NeonButton(
                        text: 'SUBMIT STEEL-MAN',
                        onPressed: () {
                          if (steelManController.text.trim().isEmpty) return;
                          Navigator.pop(context);
                          _completedSteelMans.add(round);
                          _processSendMessage(originalText, steelManText: steelManController.text.trim());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleFinishMatch() async {
    setState(() => _isAnalyzing = true);
    try {
      final evaluation = await _aiService.evaluateDebate(
        chatHistory: _messages, 
        topic: widget.topic, 
        userStance: widget.userStance,
        userElo: _userElo,
      );
      if (mounted) { setState(() => _isAnalyzing = false); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ScorecardScreen(evaluationData: evaluation))); }
    } catch (e) {
      if (mounted) { setState(() => _isAnalyzing = false); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScorecardScreen(evaluationData: {}))); }
    }
  }

  @override
  void dispose() { _messageController.dispose(); _scrollController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(),
        body: Stack(children: [
          Column(children: [
            _buildRoundProgress(),
            Expanded(child: ListView.builder(controller: _scrollController, padding: const EdgeInsets.all(20), itemCount: _messages.length, itemBuilder: (context, index) {
              final msg = _messages[index];
              return _buildChatBubble(msg['text'], msg['isAI']).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, duration: 300.ms);
            })),
            if (_isTyping) _buildTypingIndicator(),
            _isMatchOver ? _buildFinishButton() : _buildInputBar(),
          ]),
          if (_isAnalyzing) _buildLoadingOverlay(),
        ]),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.deepVoid.withOpacity(0.7),
      elevation: 0, centerTitle: false,
      leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.mutedText), onPressed: () => Navigator.pop(context)),
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          borderRadius: 8,
          borderColor: AppColors.neonPurple.withOpacity(0.3),
          child: Text('Round ${_userMessageCount.clamp(1, widget.totalRounds)} / ${widget.totalRounds}', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        if ((_userMessageCount > 0 && _userMessageCount % 3 == 0) || _userMessageCount == widget.totalRounds)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
              ),
              child: Text(
                'STEEL-MAN ROUND',
                style: GoogleFonts.spaceGrotesk(color: AppColors.electricBlue, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
          ),
        const SizedBox(height: 4),
        ShaderMask(shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds), child: Text('User vs. ${widget.opponentPersona}', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600))),
      ]),
      actions: [
        IconButton(icon: const Icon(Icons.exit_to_app, color: AppColors.defeat), tooltip: 'End Match', onPressed: _showForfeitDialog),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildRoundProgress() {
    return Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 20), child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(value: _userMessageCount / widget.totalRounds, backgroundColor: AppColors.divider, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonPurple))));
  }

  Widget _buildLoadingOverlay() {
    return Container(color: AppColors.deepVoid.withOpacity(0.9), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 48, height: 48, child: CircularProgressIndicator(color: AppColors.neonPurple, strokeWidth: 3)),
      const SizedBox(height: 24),
      ShaderMask(shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds), child: Text('The Coach is analyzing...', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
    ]))));
  }

  Widget _buildFinishButton() {
    return Container(padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 24), decoration: BoxDecoration(color: AppColors.deepVoid.withOpacity(0.8), border: Border(top: BorderSide(color: AppColors.neonPurple.withOpacity(0.2)))),
      child: NeonButton(text: 'FINISH & GET SCORE', icon: Icons.emoji_events_rounded, onPressed: _handleFinishMatch));
  }

  void _showForfeitDialog() {
    showDialog(context: context, builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.white.withOpacity(0.1))),
      title: Text('Forfeit Match?', style: GoogleFonts.spaceGrotesk(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
      content: Text('Your progress will not be saved.', style: GoogleFonts.outfit(color: AppColors.mutedText)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: GoogleFonts.outfit(color: AppColors.mutedText))),
        TextButton(onPressed: () { Navigator.pop(context); Navigator.pop(context); }, child: Text('FORFEIT', style: GoogleFonts.spaceGrotesk(color: AppColors.defeat, fontWeight: FontWeight.bold))),
      ],
    ));
  }

  Widget _buildTypingIndicator() {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8), child: Row(children: [
      const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.electricBlue)),
      const SizedBox(width: 12),
      ShaderMask(shaderCallback: (bounds) => AppColors.accentGradient.createShader(bounds), child: Text('The AI is crafting a rebuttal...', style: GoogleFonts.outfit(color: Colors.white, fontSize: 12, fontStyle: FontStyle.italic))),
    ])).animate(onPlay: (c) => c.repeat(reverse: true)).fadeIn(duration: 800.ms);
  }

  Widget _buildChatBubble(String text, bool isAI) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: isAI ? null : const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.neonPurple, Color(0xFF6B1FA0)]),
          color: isAI ? const Color(0xFF171721).withOpacity(0.6) : null,
          borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isAI ? 0 : 16), bottomRight: Radius.circular(isAI ? 16 : 0)),
          border: isAI ? Border.all(color: Colors.white.withOpacity(0.08)) : null,
          boxShadow: isAI ? null : [BoxShadow(color: AppColors.neonPurple.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Text(text, style: GoogleFonts.outfit(color: AppColors.primaryText, fontSize: 14, height: 1.4)),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      decoration: BoxDecoration(color: AppColors.deepVoid.withOpacity(0.8), border: Border(top: BorderSide(color: AppColors.neonPurple.withOpacity(0.15)))),
      child: Row(children: [
        Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(24), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: TextField(
          controller: _messageController, maxLines: null, keyboardType: TextInputType.multiline, textInputAction: TextInputAction.newline,
          style: GoogleFonts.outfit(color: AppColors.primaryText),
          decoration: InputDecoration(
            hintText: 'Type your argument...', hintStyle: GoogleFonts.outfit(color: AppColors.mutedText.withOpacity(0.5)),
            filled: true, fillColor: const Color(0xFF171721).withOpacity(0.5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: AppColors.neonPurple.withOpacity(0.5))),
          ),
        )))),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'Send Argument',
          child: GestureDetector(onTap: _handleSendMessage, child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: AppColors.accentGradient, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.neonPurple.withOpacity(0.5), blurRadius: 12, spreadRadius: 1)]),
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 24),
          )),
        ),
      ]),
    );
  }
}
