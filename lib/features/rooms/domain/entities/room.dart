import 'package:equatable/equatable.dart';

enum RoomType { private, ai, thread }
enum RoomStatus { open, concluded }

class Room extends Equatable {
  final String id;
  final String? name;
  final String? description;
  final RoomType type;
  final RoomStatus status;
  final bool isPublic;
  final String? ownerId;
  final DateTime createdAt;

  const Room({
    required this.id,
    this.name,
    this.description,
    required this.type,
    this.status = RoomStatus.open,
    this.isPublic = false,
    this.ownerId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, description, type, status, isPublic, ownerId, createdAt];
}
