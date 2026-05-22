import '../entities/chat_message.dart';

/// Contract representing the client-side AI Chat Agent Orchestrator.
/// Coordinates communication with the LLM and runs local tool calling pipelines.
abstract class AiRepository {
  /// Sends a message and returns a stream of [ChatMessage] reflecting incremental
  /// tokens, reasoning trails, and live database tool execution states.
  Stream<ChatMessage> sendMessage({
    required String message,
    required List<ChatMessage> history,
    required String role, // 'partner' (LocalBook/SalesBuddy), 'employee' (schedule), 'customer' (general)
  });
}
