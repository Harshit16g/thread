import 'package:equatable/equatable.dart';

/// Represents a single tool execution step within a conversational turn.
class ToolTask extends Equatable {
  final String id;
  final String name;
  final String label;
  final String status; // 'running', 'done', 'error'
  final String? result;

  const ToolTask({
    required this.id,
    required this.name,
    required this.label,
    required this.status,
    this.result,
  });

  ToolTask copyWith({
    String? id,
    String? name,
    String? label,
    String? status,
    String? result,
  }) {
    return ToolTask(
      id: id ?? this.id,
      name: name ?? this.name,
      label: label ?? this.label,
      status: status ?? this.status,
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [id, name, label, status, result];
}

/// Represents a single chat message inside TabL conversation history.
class ChatMessage extends Equatable {
  final String id;
  final String role; // 'user', 'assistant'
  final String content;
  final String? reasoning; // Captured from <think> tags for Qwen3/MiniMax models
  final List<ToolTask> toolQueue; // Visual queue representing live database interactions
  final bool isStreaming; // Visual state for active response generation

  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.reasoning,
    this.toolQueue = const [],
    this.isStreaming = false,
  });

  ChatMessage copyWith({
    String? id,
    String? role,
    String? content,
    String? reasoning,
    List<ToolTask>? toolQueue,
    bool? isStreaming,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      reasoning: reasoning ?? this.reasoning,
      toolQueue: toolQueue ?? this.toolQueue,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  @override
  List<Object?> get props => [id, role, content, reasoning, toolQueue, isStreaming];
}
