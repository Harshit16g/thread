import 'package:equatable/equatable.dart';

abstract class AiChatEvent extends Equatable {
  const AiChatEvent();

  @override
  List<Object?> get props => [];
}

class AiChatMessageSent extends AiChatEvent {
  final String message;
  final String role; // 'partner' | 'employee' | 'customer'

  const AiChatMessageSent({required this.message, required this.role});

  @override
  List<Object?> get props => [message, role];
}

class AiChatClearHistory extends AiChatEvent {
  const AiChatClearHistory();
}

class AiChatUpdateRole extends AiChatEvent {
  final String role;

  const AiChatUpdateRole(this.role);

  @override
  List<Object?> get props => [role];
}
