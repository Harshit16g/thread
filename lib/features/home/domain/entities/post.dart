import 'package:equatable/equatable.dart';

class Post extends Equatable {
  final String id;
  final String? roomId;
  final String authorId;
  final String content;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const Post({
    required this.id,
    this.roomId,
    required this.authorId,
    required this.content,
    this.metadata,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, roomId, authorId, content, metadata, createdAt];
}
