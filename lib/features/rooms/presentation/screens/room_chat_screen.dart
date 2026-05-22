import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/room_message.dart';
import '../../domain/repositories/room_repository.dart';
import '../bloc/room_chat_bloc.dart';
import '../bloc/states/room_chat_state.dart';
import '../bloc/events/room_chat_event.dart';
import '../widgets/proposal_card.dart';
import '../bloc/rooms_bloc.dart';
import '../bloc/events/rooms_event.dart';

class RoomChatScreen extends StatefulWidget {
  final Room room;

  const RoomChatScreen({super.key, required this.room});

  @override
  State<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends State<RoomChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  @override
  void initState() {
    super.initState();
    context.read<RoomChatBloc>().add(LoadMessagesRequested(widget.room.id));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwner = widget.room.ownerId == _currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.room.name ?? 'Chat', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.room.type.name.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.room.type == RoomType.private && isOwner)
            IconButton(
              icon: const Icon(Icons.public, color: Colors.blue),
              tooltip: 'Convert to Public Thread',
              onPressed: () => _showConvertDialog(context),
            ),
          if (widget.room.status == RoomStatus.open && isOwner)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green),
              tooltip: 'Conclude Discussion',
              onPressed: () => _showConcludeDialog(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<RoomChatBloc, RoomChatState>(
              listener: (context, state) {
                if (state is RoomChatLoaded) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                if (state is RoomChatLoading) {
                  return const Center(child: CircularProgressIndicator(color: Colors.amber));
                } else if (state is RoomChatLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      if (message.isProposal) {
                        return ProposalCard(
                          message: message,
                          onApprove: () => context.read<RoomChatBloc>().add(ApproveProposalRequested(message.id, widget.room.id)),
                          onReject: () => context.read<RoomChatBloc>().add(RejectProposalRequested(message.id)),
                        );
                      }
                      return _buildMessageBubble(message);
                    },
                  );
                }
                return const Center(child: Text('Start the conversation', style: TextStyle(color: Colors.white24)));
              },
            ),
          ),
          if (widget.room.status == RoomStatus.open)
            _buildInputArea(context)
          else
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white.withOpacity(0.02),
              child: const Center(
                child: Text(
                  'This discussion has concluded.',
                  style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(RoomMessage message) {
    final bool isMe = message.senderId == _currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.amber[800]!.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isMe ? Colors.amber[800]!.withOpacity(0.3) : Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            tooltip: 'Propose as Post',
            onPressed: () => _sendMessage(context, isProposal: true),
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _sendMessage(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.amber),
            onPressed: () => _sendMessage(context),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context, {bool isProposal = false}) {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    context.read<RoomChatBloc>().add(SendMessageRequested(
      roomId: widget.room.id,
      content: content,
      isProposal: isProposal,
    ));

    _messageController.clear();
  }

  void _showConcludeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Conclude Discussion', style: TextStyle(color: Colors.white)),
        content: const Text('This will close the discussion and prevent further messages.', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await RepositoryProvider.of<RoomRepository>(context).concludeRoom(widget.room.id);
              if (mounted) {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                context.read<RoomsBloc>().add(LoadMyRooms());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Conclude'),
          ),
        ],
      ),
    );
  }

  void _showConvertDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.room.name);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text('Convert to Public Thread', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a name for this public thread:', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Thread name...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await RepositoryProvider.of<RoomRepository>(context).convertToPublicThread(widget.room.id, controller.text);
              if (mounted) {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
                context.read<RoomsBloc>().add(LoadMyRooms());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('Make Public'),
          ),
        ],
      ),
    );
  }
}

