import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_message.dart';
import '../../domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final SupabaseClient _client;

  RoomRepositoryImpl(this._client);

  @override
  Future<List<Room>> getMyRooms() async {
    final response = await _client
        .from('room_members')
        .select('rooms(*)')
        .eq('profile_id', _client.auth.currentUser!.id);
    
    return (response as List).map((data) {
      final roomData = data['rooms'];
      return _mapToRoom(roomData);
    }).toList();
  }

  @override
  Future<Room> createRoom({
    required String? name,
    required RoomType type,
    bool isPublic = false,
  }) async {
    final response = await _client.from('rooms').insert({
      'name': name,
      'type': type.name,
      'is_public': isPublic,
      'owner_id': _client.auth.currentUser!.id,
    }).select().single();

    final room = _mapToRoom(response);

    // Auto join owner
    await _client.from('room_members').insert({
      'room_id': room.id,
      'profile_id': _client.auth.currentUser!.id,
      'role': 'owner',
    });

    return room;
  }

  @override
  Future<void> joinRoom(String roomId) async {
    await _client.from('room_members').insert({
      'room_id': roomId,
      'profile_id': _client.auth.currentUser!.id,
      'role': 'member',
    });
  }

  @override
  Future<void> concludeRoom(String roomId) async {
    await _client.from('rooms').update({
      'status': RoomStatus.concluded.name,
    }).eq('id', roomId);
  }

  @override
  Stream<List<RoomMessage>> getRoomMessages(String roomId) {
    return _client
        .from('room_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true)
        .map((data) => data.map((m) => _mapToMessage(m)).toList());
  }

  @override
  Future<void> sendMessage(String roomId, String content, {bool isProposal = false}) async {
    await _client.from('room_messages').insert({
      'room_id': roomId,
      'sender_id': _client.auth.currentUser!.id,
      'content': content,
      'is_proposal': isProposal,
      'proposal_status': isProposal ? ProposalStatus.pending.name : null,
    });
  }

  @override
  Future<void> approveProposal(String messageId, String roomId) async {
    final message = await _client.from('room_messages').select().eq('id', messageId).single();
    
    await _client.from('room_messages').update({
      'proposal_status': ProposalStatus.approved.name,
      'approved_by': _client.auth.currentUser!.id,
    }).eq('id', messageId);

    // Create a public post from this proposal
    await _client.from('posts').insert({
      'room_id': roomId,
      'author_id': message['sender_id'],
      'content': message['content'],
    });
  }

  @override
  Future<void> rejectProposal(String messageId) async {
    await _client.from('room_messages').update({
      'proposal_status': ProposalStatus.rejected.name,
    }).eq('id', messageId);
  }

  @override
  Future<Room> convertToPublicThread(String roomId, String name) async {
    final response = await _client.from('rooms').update({
      'type': RoomType.thread.name,
      'is_public': true,
      'name': name,
    }).eq('id', roomId).select().single();

    return _mapToRoom(response);
  }

  Room _mapToRoom(Map<String, dynamic> data) {
    return Room(
      id: data['id'],
      name: data['name'],
      description: data['description'],
      type: RoomType.values.byName(data['type']),
      status: RoomStatus.values.byName(data['status']),
      isPublic: data['is_public'],
      ownerId: data['owner_id'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }

  RoomMessage _mapToMessage(Map<String, dynamic> data) {
    return RoomMessage(
      id: data['id'],
      roomId: data['room_id'],
      senderId: data['sender_id'],
      content: data['content'],
      isProposal: data['is_proposal'],
      proposalStatus: data['proposal_status'] != null 
          ? ProposalStatus.values.byName(data['proposal_status']) 
          : null,
      approvedBy: data['approved_by'],
      createdAt: DateTime.parse(data['created_at']),
    );
  }
}
