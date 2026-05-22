import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/rooms_bloc.dart';
import '../bloc/states/rooms_state.dart';
import '../bloc/events/rooms_event.dart';
import '../../domain/entities/room.dart';
import '../../domain/repositories/room_repository.dart';

import 'room_chat_screen.dart';
import '../bloc/room_chat_bloc.dart';

class RoomsScreen extends StatelessWidget {
  const RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        title: const Text('Discussions', style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
            onPressed: () => _showCreateRoomDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<RoomsBloc, RoomsState>(
        builder: (context, state) {
          if (state is RoomsLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          } else if (state is RoomsLoaded) {
            if (state.rooms.isEmpty) {
              return _buildEmptyState(context);
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.rooms.length,
              itemBuilder: (context, index) {
                final room = state.rooms[index];
                return _buildRoomTile(context, room);
              },
            );
          } else if (state is RoomsError) {
            return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)));
          }
          return const Center(child: Text('No discussions yet', style: TextStyle(color: Colors.white38)));
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          const Text('No discussions yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateRoomDialog(context),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
            child: const Text('Start New Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, Room room) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: _getRoomColor(room.type),
            child: Icon(_getRoomIcon(room.type), color: Colors.white, size: 20),
          ),
          title: Text(
            room.name ?? 'Untitled Room',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            room.type.name.toUpperCase(),
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.white24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (routeContext) => BlocProvider(
                  create: (blocContext) => RoomChatBloc(
                    RepositoryProvider.of<RoomRepository>(context),
                  ),
                  child: RoomChatScreen(room: room),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getRoomIcon(RoomType type) {
    switch (type) {
      case RoomType.private: return Icons.person_outline;
      case RoomType.ai: return Icons.auto_awesome;
      case RoomType.thread: return Icons.groups_outlined;
    }
  }

  Color _getRoomColor(RoomType type) {
    switch (type) {
      case RoomType.private: return Colors.blueGrey;
      case RoomType.ai: return Colors.amber[800]!;
      case RoomType.thread: return Colors.teal;
    }
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('New Discussion', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCreateOption(
              context,
              'Personal Chat',
              'Chat with another human',
              Icons.person_outline,
              () {
                Navigator.pop(dialogContext);
                context.read<RoomsBloc>().add(const CreateRoomRequested(type: RoomType.private));
              },
            ),
            const SizedBox(height: 12),
            _buildCreateOption(
              context,
              'AI Collaboration',
              'Brainstorm with TabL AI',
              Icons.auto_awesome,
              () {
                Navigator.pop(dialogContext);
                context.read<RoomsBloc>().add(const CreateRoomRequested(type: RoomType.ai, name: 'AI Brainstorm'));
              },
            ),
            const SizedBox(height: 12),
            _buildCreateOption(
              context,
              'Public Thread',
              'Start a group discussion',
              Icons.groups_outlined,
              () {
                Navigator.pop(dialogContext);
                context.read<RoomsBloc>().add(const CreateRoomRequested(type: RoomType.thread, isPublic: true, name: 'New Thread'));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateOption(BuildContext context, String title, String sub, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
