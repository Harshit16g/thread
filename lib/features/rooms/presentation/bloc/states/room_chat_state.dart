import 'package:equatable/equatable.dart';
import '../../../domain/entities/room_message.dart';

abstract class RoomChatState extends Equatable {
  const RoomChatState();
  @override
  List<Object?> get props => [];
}

class RoomChatInitial extends RoomChatState {}

class RoomChatLoading extends RoomChatState {}

class RoomChatLoaded extends RoomChatState {
  final List<RoomMessage> messages;
  const RoomChatLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class RoomChatError extends RoomChatState {
  final String message;
  const RoomChatError(this.message);
  @override
  List<Object?> get props => [message];
}
