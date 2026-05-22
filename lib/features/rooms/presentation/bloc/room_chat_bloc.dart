import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/entities/room_message.dart';
import 'events/room_chat_event.dart';
import 'states/room_chat_state.dart';

class RoomChatBloc extends Bloc<RoomChatEvent, RoomChatState> {
  final RoomRepository _roomRepository;
  StreamSubscription? _messagesSubscription;

  RoomChatBloc(this._roomRepository) : super(RoomChatInitial()) {
    on<LoadMessagesRequested>(_onLoadMessages);
    on<SendMessageRequested>(_onSendMessage);
    on<ApproveProposalRequested>(_onApproveProposal);
    on<RejectProposalRequested>(_onRejectProposal);
    on<_UpdateMessages>(_onUpdateMessages);
    on<_SetAiTyping>(_onSetAiTyping);
  }

  Future<void> _onLoadMessages(LoadMessagesRequested event, Emitter<RoomChatState> emit) async {
    _messagesSubscription?.cancel();
    emit(RoomChatLoading());
    
    _messagesSubscription = _roomRepository.getRoomMessages(event.roomId).listen(
      (messages) => add(_UpdateMessages(messages)),
      onError: (error) => emit(RoomChatError(error.toString())),
    );
  }

  void _onUpdateMessages(_UpdateMessages event, Emitter<RoomChatState> emit) {
    final currentState = state;
    final bool wasTyping = currentState is RoomChatLoaded && currentState.isAiTyping;
    // If new messages arrived and AI was typing, check if AI message is now present
    final bool aiJustResponded = wasTyping && event.messages.isNotEmpty &&
        event.messages.last.senderId == '00000000-0000-0000-0000-000000000000';
    emit(RoomChatLoaded(event.messages, isAiTyping: wasTyping && !aiJustResponded));
  }

  void _onSetAiTyping(_SetAiTyping event, Emitter<RoomChatState> emit) {
    final currentState = state;
    if (currentState is RoomChatLoaded) {
      emit(RoomChatLoaded(currentState.messages, isAiTyping: event.isTyping));
    }
  }

  Future<void> _onSendMessage(SendMessageRequested event, Emitter<RoomChatState> emit) async {
    try {
      await _roomRepository.sendMessage(
        event.roomId,
        event.content,
        isProposal: event.isProposal,
      );

      // If this is an AI room, trigger the AI response
      if (event.roomType == 'ai') {
        add(const _SetAiTyping(true));

        // Gather current messages for context
        final currentState = state;
        List<RoomMessage> history = [];
        if (currentState is RoomChatLoaded) {
          history = currentState.messages;
        }

        try {
          await _roomRepository.sendAiResponse(
            event.roomId,
            event.content,
            history,
          );
        } catch (e) {
          print('[TabL/RoomChatBloc] AI response error: $e');
        }
        add(const _SetAiTyping(false));
      }
    } catch (e) {
      emit(RoomChatError(e.toString()));
    }
  }

  Future<void> _onApproveProposal(ApproveProposalRequested event, Emitter<RoomChatState> emit) async {
    try {
      await _roomRepository.approveProposal(event.messageId, event.roomId);
    } catch (e) {
      emit(RoomChatError(e.toString()));
    }
  }

  Future<void> _onRejectProposal(RejectProposalRequested event, Emitter<RoomChatState> emit) async {
    try {
      await _roomRepository.rejectProposal(event.messageId);
    } catch (e) {
      emit(RoomChatError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}

class _UpdateMessages extends RoomChatEvent {
  final List<RoomMessage> messages;
  const _UpdateMessages(this.messages);
}

class _SetAiTyping extends RoomChatEvent {
  final bool isTyping;
  const _SetAiTyping(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}
