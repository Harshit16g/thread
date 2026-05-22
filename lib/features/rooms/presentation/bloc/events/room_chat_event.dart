import 'package:equatable/equatable.dart';

abstract class RoomChatEvent extends Equatable {
  const RoomChatEvent();
  @override
  List<Object?> get props => [];
}

class LoadMessagesRequested extends RoomChatEvent {
  final String roomId;
  const LoadMessagesRequested(this.roomId);
  @override
  List<Object?> get props => [roomId];
}

class SendMessageRequested extends RoomChatEvent {
  final String roomId;
  final String content;
  final bool isProposal;
  final String roomType; // 'private', 'ai', 'thread'

  const SendMessageRequested({
    required this.roomId,
    required this.content,
    this.isProposal = false,
    this.roomType = 'private',
  });

  @override
  List<Object?> get props => [roomId, content, isProposal, roomType];
}

class ApproveProposalRequested extends RoomChatEvent {
  final String messageId;
  final String roomId;
  const ApproveProposalRequested(this.messageId, this.roomId);
  @override
  List<Object?> get props => [messageId, roomId];
}

class RejectProposalRequested extends RoomChatEvent {
  final String messageId;
  const RejectProposalRequested(this.messageId);
  @override
  List<Object?> get props => [messageId];
}
