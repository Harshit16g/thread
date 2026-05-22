import '../entities/room.dart';
import '../entities/room_message.dart';

abstract class RoomRepository {
  Future<List<Room>> getMyRooms();
  Future<Room> createRoom({
    required String? name,
    required RoomType type,
    bool isPublic = false,
  });
  Future<void> joinRoom(String roomId);
  Future<void> concludeRoom(String roomId);
  
  Stream<List<RoomMessage>> getRoomMessages(String roomId);
  Future<void> sendMessage(String roomId, String content, {bool isProposal = false});
  Future<void> approveProposal(String messageId, String roomId);
  Future<void> rejectProposal(String messageId);

  Future<Room> convertToPublicThread(String roomId, String name);

  /// Sends the user's message to the AI and inserts the AI response into the room.
  Future<void> sendAiResponse(String roomId, String userMessage, List<RoomMessage> history);
}
