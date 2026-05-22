import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    if (state is! RoomChatLoaded) {
      emit(RoomChatLoading());
    }
    
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
    final currentState = state;
    List<RoomMessage> currentMessages = [];
    bool isAiTyping = false;
    
    if (currentState is RoomChatLoaded) {
      currentMessages = List.from(currentState.messages);
      isAiTyping = currentState.isAiTyping;
    }

    // 1. Create the user message entity optimistically
    final optimisticUserMessage = RoomMessage(
      id: 'opt-user-${DateTime.now().millisecondsSinceEpoch}',
      roomId: event.roomId,
      senderId: Supabase.instance.client.auth.currentUser?.id ?? 'user',
      content: event.content,
      isProposal: event.isProposal,
      proposalStatus: event.isProposal ? ProposalStatus.pending : null,
      createdAt: DateTime.now(),
    );

    // 2. Optimistically append and emit immediately so the bubble renders instantly
    final updatedMessages = List<RoomMessage>.from(currentMessages)..add(optimisticUserMessage);
    emit(RoomChatLoaded(updatedMessages, isAiTyping: isAiTyping));

    try {
      // 3. Send message to the database
      await _roomRepository.sendMessage(
        event.roomId,
        event.content,
        isProposal: event.isProposal,
      );

      // Force a background database fetch to swap our optimistic message with the database record
      add(LoadMessagesRequested(event.roomId));

      // 4. If this is an AI room, trigger the AI response
      if (event.roomType == 'ai') {
        final freshState = state;
        final listForContext = freshState is RoomChatLoaded ? freshState.messages : updatedMessages;
        emit(RoomChatLoaded(listForContext, isAiTyping: true));

        try {
          await _roomRepository.sendAiResponse(
            event.roomId,
            event.content,
            listForContext,
          );
        } catch (e) {
          print('[TabL/RoomChatBloc] AI response error: $e');
        }
        
        // After AI completes, force a fresh fetch to grab the AI response message from the DB
        add(LoadMessagesRequested(event.roomId));
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
