import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class AIDebateService {
  Future<String> getResponse(
    String userMessage,
    String topic,
    String persona,
    int userElo,
    List<Content> chatHistory,
    int currentRound,
    int totalRounds,
  ) async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
    
    String steelManInstruction = '';
    // Apply steel-manning after every 3 rounds and before the final round.
    if ((currentRound > 0 && currentRound % 3 == 0) || currentRound == totalRounds - 1) {
      steelManInstruction = "\n\nSteel-manning Rule: You MUST begin this response by briefly 'steel-manning' the user's argument—summarize their strongest point fairly before you counter it.";
    }

    final systemInstruction = '''
Role: You are debating the topic: '$topic'. Your persona is: '$persona'. You must adopt this persona entirely.

Adaptive Difficulty: The user has an Elo rating of $userElo. If Elo is below 1200, use simple logic and accessible language. If Elo is 1200-1800, use standard debate tactics. If Elo is above 1800, use advanced rhetorical devices, point out logical fallacies, and be intellectually ruthless.\$steelManInstruction

Format: Keep responses concise (under 100 words).
''';

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(systemInstruction),
    );

    final chat = model.startChat(history: chatHistory);
    final response = await chat.sendMessage(Content.text(userMessage));

    return response.text ?? '';
  }

  Future<Map<String, dynamic>> evaluateDebate({
    required List<Map<String, dynamic>> chatHistory,
    required String topic,
    required String userStance,
  }) async {
    final String? apiKey = dotenv.env['GEMINI_API_KEY'];
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey ?? '',
    );

    try {
      final historyString = chatHistory.map((m) => '\${m['isAI'] ? 'Opponent' : 'User'}: \${m['text']}').join('\n');
      
      final evaluationPrompt = 'System Instruction: You are a strict, impartial debate judge. '
          'We are debating the topic: \$topic. The user is taking the \$userStance stance. '
          'Evaluate the user\\'s performance in the following debate history:\n\n'
          '\$historyString\n\n'
          'Output ONLY a valid JSON object with NO markdown, NO formatting, and NO extra text. '
          'The JSON must contain exactly these keys with integer values for scores:\n'
          '{\n'
          '  "clarityScore": (int 0-100),\n'
          '  "logicScore": (int 0-100),\n'
          '  "rebuttalScore": (int 0-100),\n'
          '  "fallacyScore": (int 0-100),\n'
          '  "bestArgumentHighlight": "short string quoting the user\\'s best point",\n'
          '  "coachFeedback": "A concise paragraph of constructive feedback for the user\\'s overall debate strategy."\n'
          '}';

      final content = [Content.text(evaluationPrompt)];
      final response = await model.generateContent(content);
      final responseText = response.text ?? '{}';
      
      String cleanedJson = responseText.trim();
      if (cleanedJson.startsWith('```json')) cleanedJson = cleanedJson.substring(7);
      if (cleanedJson.endsWith('```')) cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      cleanedJson = cleanedJson.trim();

      return json.decode(cleanedJson) as Map<String, dynamic>;
    } catch (e) {
      return {
        'clarityScore': 50,
        'logicScore': 50,
        'rebuttalScore': 50,
        'fallacyScore': 20,
        'bestArgumentHighlight': 'Could not analyze debate performance.',
        'coachFeedback': 'Analysis engine encountered an error. Please try again in the next match.'
      };
    }
  }
}
