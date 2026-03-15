import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ai_debater_service.dart';
import '../scorecard/scorecard_screen.dart';

class ArenaScreen extends StatefulWidget {
  final String topic;
  final String userStance;
  final String opponentPersona;

  const ArenaScreen({
    super.key,
    required this.topic,
    required this.userStance,
    required this.opponentPersona,
  });

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiDebaterService _aiService = AiDebaterService();

  late final List<Map<String, dynamic>> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      {
        'isAI': true,
        'text': 'I am the ${widget.opponentPersona}. Let us debate ${widget.topic}. Make your opening move.',
      },
    ];
  }

  bool _isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add({'isAI': false, 'text': text});
      _messageController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final response = await _aiService.getOpponentResponse(
        topic: widget.topic,
        userStance: widget.userStance,
        opponentPersona: widget.opponentPersona,
        userMessage: text,
      );
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({'isAI': true, 'text': response});
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('ArenaScreen Error: $e');
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'isAI': true,
            'text': 'Error: Failed to connect to the debate engine. Ensure your API key is valid.'
          });
        });
        _scrollToBottom();
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Opening Argument: 1 of 4',
              style: GoogleFonts.publicSans(
                color: AppColors.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'User vs. ${widget.opponentPersona}',
              style: GoogleFonts.publicSans(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: AppColors.accent),
            tooltip: 'End Match',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScorecardScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                return _buildChatBubble(message['text'], message['isAI']);
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Opponent is typing...',
          style: GoogleFonts.publicSans(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isAI) {
    return Align(
      alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isAI ? const Color(0xFF2C2C2C) : const Color(0xFF3D3D3D),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isAI ? 0 : 16),
            bottomRight: Radius.circular(isAI ? 16 : 0),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.publicSans(
            color: AppColors.primaryText,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onSubmitted: (_) => _handleSendMessage(),
              style: GoogleFonts.publicSans(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Type your argument...',
                hintStyle: GoogleFonts.publicSans(
                  color: AppColors.secondaryText.withOpacity(0.5),
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _handleSendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
