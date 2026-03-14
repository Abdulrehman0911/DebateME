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
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'You are a ruthless, highly logical debate opponent. '
          'The user is arguing against you. '
          'Keep your response to 2 short, punchy paragraphs max.'
        ),
      );
    } catch (e) {
      debugPrint('AiDebaterService Initialization Error: $e');
      rethrow;
    }
  }

  Future<String> getOpponentResponse(String userMessage) async {
    try {
      final content = [Content.text(userMessage)];
      final response = await _model.generateContent(content);
      return response.text ?? 'I have no rebuttal for such a weak argument.';
    } catch (e) {
      debugPrint('AiDebaterService getOpponentResponse Error: $e');
      rethrow;
    }
  }
}
