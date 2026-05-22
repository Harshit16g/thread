import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/ai_repository.dart';
import 'events/ai_chat_event.dart';
import 'states/ai_chat_state.dart';

class AiChatBloc extends Bloc<AiChatEvent, AiChatState> {
  final AiRepository _aiRepository;

  AiChatBloc({required AiRepository aiRepository})
      : _aiRepository = aiRepository,
        super(const AiChatState()) {
    on<AiChatMessageSent>(_onMessageSent);
    on<AiChatClearHistory>(_onClearHistory);
    on<AiChatUpdateRole>(_onUpdateRole);
  }

  Future<void> _onMessageSent(
    AiChatMessageSent event,
    Emitter<AiChatState> emit,
  ) async {
    if (event.message.trim().isEmpty) return;

    // 1. Create and append the user message
    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: event.message.trim(),
    );

    final List<ChatMessage> historyForAi = List.from(state.messages);

    final updatedMessages = List<ChatMessage>.from(state.messages)..add(userMessage);
    emit(state.copyWith(
      messages: updatedMessages,
      isStreaming: true,
      errorMessage: null,
    ));

    try {
      // 2. Listen to streaming AI turns & yield states in real time
      await emit.forEach<ChatMessage>(
        _aiRepository.sendMessage(
          message: event.message.trim(),
          history: historyForAi,
          role: event.role,
        ),
        onData: (assistantMessage) {
          final messagesCopy = List<ChatMessage>.from(state.messages);
          final existingIndex = messagesCopy.indexWhere((m) => m.id == assistantMessage.id);

          if (existingIndex != -1) {
            messagesCopy[existingIndex] = assistantMessage;
          } else {
            messagesCopy.add(assistantMessage);
          }

          return state.copyWith(
            messages: messagesCopy,
            isStreaming: assistantMessage.isStreaming,
          );
        },
        onError: (error, stackTrace) {
          print('[TabL/AiChatBloc] Stream error: $error');
          return state.copyWith(
            isStreaming: false,
            errorMessage: 'Service connection interrupted: ${error.toString()}',
          );
        },
      );
    } catch (e) {
      print('[TabL/AiChatBloc] Critical BLoC exception: $e');
      emit(state.copyWith(
        isStreaming: false,
        errorMessage: 'An unexpected system error occurred.',
      ));
    }
  }

  void _onClearHistory(
    AiChatClearHistory event,
    Emitter<AiChatState> emit,
  ) {
    emit(AiChatState(currentRole: state.currentRole));
  }

  void _onUpdateRole(
    AiChatUpdateRole event,
    Emitter<AiChatState> emit,
  ) {
    emit(state.copyWith(currentRole: event.role));
  }
}
