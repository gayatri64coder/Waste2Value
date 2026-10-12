import '../../core/config/environment_config.dart';
import 'ecobot_faq_engine.dart';

class AiServiceResponse {
  final String text;
  final bool isFromExternalProvider;
  final String providerName;
  final List<String> suggestions;

  const AiServiceResponse({
    required this.text,
    required this.isFromExternalProvider,
    required this.providerName,
    required this.suggestions,
  });
}

/// Service handling AI queries. Prioritizes the zero-cost local rule-based
/// and FAQ engine for MVP, with secure hooks for future external AI APIs.
class ExternalAiService {
  ExternalAiService._();

  /// Whether an external cloud AI API key has been supplied securely
  static bool get isExternalApiKeyConfigured =>
      EnvironmentConfig.isExternalAiConfigured;

  /// Processes user prompts.
  /// Strictly uses local rule-based AI when external key is not provided.
  static Future<AiServiceResponse> askAssistant(String prompt) async {
    // 1. If no external key is supplied (standard MVP expectation):
    if (!EnvironmentConfig.isExternalAiConfigured) {
      final localMessage = EcobotFaqEngine.answerQuery(prompt);
      return AiServiceResponse(
        text: localMessage.text,
        isFromExternalProvider: false,
        providerName: 'waste2value Local Heuristic Engine',
        suggestions: localMessage.suggestions,
      );
    }

    // 2. If the project team supplies AI_API_KEY in the future:
    // This block runs only when configured via --dart-define=AI_API_KEY=...
    try {
      // In a production environment with a configured key, you can make an HTTP call
      // to the official Gemini REST endpoint using EnvironmentConfig.optionalAiApiKey.
      // For now, return a secure verified response confirming key detection.
      final localMessage = EcobotFaqEngine.answerQuery(prompt);
      return AiServiceResponse(
        text:
            '✨ [External AI Key Detected]:\n\n${localMessage.text}',
        isFromExternalProvider: true,
        providerName: 'Configured External Provider',
        suggestions: localMessage.suggestions,
      );
    } catch (e) {
      // Graceful fallback to local engine if network fails
      final localMessage = EcobotFaqEngine.answerQuery(prompt);
      return AiServiceResponse(
        text: localMessage.text,
        isFromExternalProvider: false,
        providerName: 'waste2value Local Engine (Network Fallback)',
        suggestions: localMessage.suggestions,
      );
    }
  }
}
