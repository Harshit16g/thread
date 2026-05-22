import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/room_repository.dart';
import 'events/rooms_event.dart';
import 'states/rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final RoomRepository _roomRepository;

  RoomsBloc(this._roomRepository) : super(RoomsInitial()) {
    on<LoadMyRooms>(_onLoadMyRooms);
    on<CreateRoomRequested>(_onCreateRoom);
  }

  Future<void> _onLoadMyRooms(LoadMyRooms event, Emitter<RoomsState> emit) async {
    emit(RoomsLoading());
    try {
      final rooms = await _roomRepository.getMyRooms();
      emit(RoomsLoaded(rooms));
    } catch (e) {
      emit(RoomsError(e.toString()));
    }
  }

  Future<void> _onCreateRoom(CreateRoomRequested event, Emitter<RoomsState> emit) async {
    try {
      await _roomRepository.createRoom(
        name: event.name,
        type: event.type,
        isPublic: event.isPublic,
      );
      add(LoadMyRooms());
    } catch (e) {
      emit(RoomsError(e.toString()));
    }
  }
}
