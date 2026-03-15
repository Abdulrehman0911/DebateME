import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
}
