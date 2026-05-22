import 'package:equatable/equatable.dart';
import '../../../domain/entities/chat_message.dart';

class AiChatState extends Equatable {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? errorMessage;
  final String currentRole; // 'partner' | 'employee' | 'customer'

  const AiChatState({
    this.messages = const [],
    this.isStreaming = false,
    this.errorMessage,
    this.currentRole = 'partner',
  });

  AiChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? errorMessage,
    String? currentRole,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      errorMessage: errorMessage,
      currentRole: currentRole ?? this.currentRole,
    );
  }

  @override
  List<Object?> get props => [messages, isStreaming, errorMessage, currentRole];
}
