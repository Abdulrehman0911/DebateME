import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class AiDebaterService {
  late final GenerativeModel _model;

  AiDebaterService() {
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      debugPrint('AiDebaterService: Key loaded, length: ${apiKey?.length}');
      
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY not found in environment variables');
      }
      
      // Using 'gemini-1.5-flash' which is the standard model name.
      // We'll move system instructions into the prompt to ensure maximum compatibility 
      // with the backend API versioning.
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );
    } catch (e) {
      debugPrint('AiDebaterService Initialization Error: $e');
      rethrow;
    }
  }

  Future<String> getOpponentResponse({
    required String topic,
    required String userStance,
    required String opponentPersona,
    required String userMessage,
  }) async {
    try {
      // Injecting the context-aware personality directly into the prompt context.
      final fullPrompt = 'System Instruction: You are an expert debater roleplaying as the $opponentPersona. '
          'We are debating the topic: $topic. The user is taking the $userStance stance. '
          'You must fiercely argue the opposite side. Stay completely in character as the $opponentPersona. '
          'Keep your responses punchy and under 2 paragraphs.\n\n'
          'User Argument: $userMessage';
          
      final content = [Content.text(fullPrompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'I have no rebuttal for such a weak argument.';
    } catch (e) {
      debugPrint('AiDebaterService getOpponentResponse Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> evaluateDebate({
    required List<Map<String, dynamic>> chatHistory,
    required String topic,
    required String userStance,
  }) async {
    try {
      final historyString = chatHistory.map((m) => '${m['isAI'] ? 'Opponent' : 'User'}: ${m['text']}').join('\n');
      
      final evaluationPrompt = 'System Instruction: You are a strict, impartial debate judge. '
          'We are debating the topic: $topic. The user is taking the $userStance stance. '
          'Evaluate the user\'s performance in the following debate history:\n\n'
          '$historyString\n\n'
          'Output ONLY a valid JSON object with NO markdown, NO formatting, and NO extra text. '
          'The JSON must contain exactly these keys with integer values for scores:\n'
          '{\n'
          '  "clarityScore": (int 0-100),\n'
          '  "logicScore": (int 0-100),\n'
          '  "rebuttalScore": (int 0-100),\n'
          '  "fallacyScore": (int 0-100),\n'
          '  "bestArgumentHighlight": "short string quoting the user\'s best point",\n'
          '  "coachFeedback": "A concise paragraph of constructive feedback for the user\'s overall debate strategy."\n'
          '}';

      final content = [Content.text(evaluationPrompt)];
      final response = await _model.generateContent(content);
      final responseText = response.text ?? '{}';
      
      // Attempt to clean the response if some markdown slipped in
      String cleanedJson = responseText.trim();
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7);
      }
      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      }
      cleanedJson = cleanedJson.trim();

      return json.decode(cleanedJson) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AiDebaterService evaluateDebate Error: $e');
      // Return dummy data on failure to prevent app crash
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
