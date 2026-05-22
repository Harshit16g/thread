import 'package:equatable/equatable.dart';
import '../../../domain/entities/room.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();
  @override
  List<Object?> get props => [];
}

class LoadMyRooms extends RoomsEvent {}

class CreateRoomRequested extends RoomsEvent {
  final String? name;
  final RoomType type;
  final bool isPublic;

  const CreateRoomRequested({this.name, required this.type, this.isPublic = false});

  @override
  List<Object?> get props => [name, type, isPublic];
}
