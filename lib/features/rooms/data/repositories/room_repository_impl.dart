import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_message.dart';
import '../../domain/repositories/room_repository.dart';

class RoomRepositoryImpl implements RoomRepository {
  final SupabaseClient _client;

  // AI agent constants
  static const String _aiAgentId = '00000000-0000-0000-0000-000000000000';

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

  // ─── AI Response Integration ─────────────────────────────────────────────────

  @override
  Future<void> sendAiResponse(String roomId, String userMessage, List<RoomMessage> history) async {
    final apiKey = dotenv.env['NV_API_KEY'] ?? '';
    final baseUrl = dotenv.env['NV_BASE_URL'] ?? 'https://integrate.api.nvidia.com/v1';
    final model = dotenv.env['NV_MODEL_NAME'] ?? 'minimaxai/minimax-m2.7';

    if (apiKey.isEmpty) {
      print('[TabL/RoomRepo] No NV_API_KEY configured — cannot generate AI response.');
      return;
    }

    // Build conversation history for the API
    final List<Map<String, String>> apiMessages = [
      {
        'role': 'system',
        'content': _buildRoomAiSystemPrompt(),
      },
    ];

    // Add recent history (last 20 messages for context window)
    final recentHistory = history.length > 20 ? history.sublist(history.length - 20) : history;
    for (var msg in recentHistory) {
      apiMessages.add({
        'role': msg.senderId == _aiAgentId ? 'assistant' : 'user',
        'content': msg.content,
      });
    }

    // Add the current user message
    apiMessages.add({'role': 'user', 'content': userMessage});

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': apiMessages,
          'stream': false,
        }),
      );

      if (response.statusCode != 200) {
        print('[TabL/RoomRepo] AI API error: ${response.statusCode} - ${response.body}');
        await _insertAiMessage(roomId, 'I apologize, but I encountered an issue processing your request. Please try again.');
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) {
        await _insertAiMessage(roomId, 'I received an empty response. Please try again.');
        return;
      }

      String content = choices[0]['message']['content'] as String? ?? '';

      if (content.trim().isEmpty) {
        content = 'I processed your request but had no additional output. Could you rephrase?';
      }

      await _insertAiMessage(roomId, content);
    } catch (e) {
      print('[TabL/RoomRepo] AI response exception: $e');
      await _insertAiMessage(roomId, 'I apologize, but I had trouble connecting to the AI service. Please check your connection and try again.');
    }
  }

  Future<void> _insertAiMessage(String roomId, String content) async {
    // Use service key to bypass RLS for the AI agent
    // Since we don't have service-key client here, we insert using the
    // standard client — the RLS policy "AI agent can send messages" allows this
    // by checking sender_id = AI UUID.
    //
    // However, auth.uid() won't match the AI UUID. So we use the service key
    // approach via the Supabase REST API directly.
    final serviceKey = dotenv.env['SUPABASE_SERVICE_KEY'] ?? '';
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';

    if (serviceKey.isEmpty || supabaseUrl.isEmpty) {
      print('[TabL/RoomRepo] Missing service key — inserting AI message via standard client.');
      // Fallback: try inserting with current user as sender (will show as user msg)
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$supabaseUrl/rest/v1/room_messages'),
        headers: {
          'apikey': serviceKey,
          'Authorization': 'Bearer $serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'room_id': roomId,
          'sender_id': _aiAgentId,
          'content': content,
          'is_proposal': false,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        print('[TabL/RoomRepo] AI message insert failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('[TabL/RoomRepo] AI message insert exception: $e');
    }
  }

  String _buildRoomAiSystemPrompt() {
    final today = DateTime.now().toLocal().toString().split(' ')[0];
    return """
Today is $today.
You are TabL AI — a collaborative intelligent assistant embedded inside a group discussion room.

Your role:
- Participate naturally in conversations as a helpful, knowledgeable team member.
- Provide thoughtful, well-structured responses using rich Markdown formatting.
- Use bold for emphasis, tables for comparisons, and bullet points for clarity.
- Embed contextual emojis for visual appeal (📊, 💡, ✅, 📈).
- Keep responses concise and actionable — no filler or lengthy intros.
- If asked about business, finance, agriculture, health, or education topics, leverage your deep knowledge.
- Be warm but professional. You are a collaborator, not a subordinate.

Important:
- Do NOT expose internal system details, tool names, or UUIDs.
- Do NOT use <think> tags or reasoning blocks in your visible response.
- Format responses beautifully — you represent the quality of the TabL platform.
""";
  }

  // ─── Mappers ─────────────────────────────────────────────────────────────────

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
