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
  }

  Future<void> _onLoadMessages(LoadMessagesRequested event, Emitter<RoomChatState> emit) async {
    _messagesSubscription?.cancel();
    emit(RoomChatLoading());
    
    _messagesSubscription = _roomRepository.getRoomMessages(event.roomId).listen(
      (messages) => add(_UpdateMessages(messages)),
      onError: (error) => emit(RoomChatError(error.toString())),
    );
  }

  // Internal event to handle stream updates
  void _onUpdateMessages(_UpdateMessages event, Emitter<RoomChatState> emit) {
    emit(RoomChatLoaded(event.messages));
  }

  Future<void> _onSendMessage(SendMessageRequested event, Emitter<RoomChatState> emit) async {
    try {
      await _roomRepository.sendMessage(
        event.roomId,
        event.content,
        isProposal: event.isProposal,
      );
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
