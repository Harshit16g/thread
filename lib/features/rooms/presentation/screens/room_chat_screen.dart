import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tabl/core/services/ideas_service.dart';
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

class _RoomChatScreenState extends State<RoomChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

  static const String _aiAgentId = '00000000-0000-0000-0000-000000000000';

  AnimationController? _typingDotController;
  late final MarkdownStyleSheet _aiMarkdownStyleSheet;

  // Dynamic animated renaming state
  late String _displayedRoomName;
  StreamSubscription? _roomSubscription;
  double _appBarTitleOpacity = 1.0;
  bool _isRenaming = false;

  Future<void> _animateRoomRename(String newName) async {
    if (_isRenaming || !mounted) return;
    _isRenaming = true;

    // 1. Vanish animation (Fade Out)
    for (double o = 1.0; o >= 0.0; o -= 0.1) {
      await Future.delayed(const Duration(milliseconds: 25));
      if (!mounted) return;
      setState(() {
        _appBarTitleOpacity = o.clamp(0.0, 1.0);
      });
    }

    if (!mounted) return;
    setState(() {
      _displayedRoomName = "";
      _appBarTitleOpacity = 1.0; // Reset opacity for typewriter
    });

    // 2. Typewriter animation (Appear word by word)
    final words = newName.split(' ');
    String currentBuild = "";
    for (int i = 0; i < words.length; i++) {
      await Future.delayed(const Duration(milliseconds: 160));
      if (!mounted) return;
      currentBuild += (i == 0 ? "" : " ") + words[i];
      setState(() {
        _displayedRoomName = currentBuild;
      });
    }

    _isRenaming = false;
  }

  // Cached heavy decorations for high frame-rate rendering
  late final BoxDecoration _aiBubbleDecoration;
  late final BoxDecoration _userBubbleDecorationMe;
  late final BoxDecoration _userBubbleDecorationOther;
  late final BoxDecoration _inputAreaDecoration;
  late final BoxDecoration _textFieldWrapperDecoration;
  late final BoxDecoration _typingIndicatorDecoration;

  @override
  void initState() {
    super.initState();
    _displayedRoomName = widget.room.name ?? 'Chat';
    
    // Realtime Supabase listener to catch background AI room renaming!
    _roomSubscription = Supabase.instance.client
        .from('rooms')
        .stream(primaryKey: ['id'])
        .eq('id', widget.room.id)
        .listen((data) {
          if (data.isNotEmpty) {
            final newName = data.first['name'] as String?;
            if (newName != null && newName != _displayedRoomName && !_isRenaming) {
              _animateRoomRename(newName);
            }
          }
        });

    context.read<RoomChatBloc>().add(LoadMessagesRequested(widget.room.id));
    _typingDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _aiMarkdownStyleSheet = MarkdownStyleSheet(
      p: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70, height: 1.55),
      strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      em: TextStyle(fontStyle: FontStyle.italic, color: Colors.white.withValues(alpha: 0.6)),
      tableBody: const TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Colors.white60),
      tableHead: TextStyle(fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber[700]),
      tableBorder: TableBorder.all(color: Colors.white.withValues(alpha: 0.06)),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      listBullet: TextStyle(color: Colors.amber[700], fontSize: 14),
      code: TextStyle(fontFamily: 'monospace', fontSize: 13, color: Colors.amber[200], backgroundColor: Colors.white.withValues(alpha: 0.05)),
      codeblockDecoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
      h1: TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber[600]),
      h2: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber[700]),
      h3: const TextStyle(fontFamily: 'Outfit', fontSize: 14.5, fontWeight: FontWeight.bold, color: Colors.white),
      blockquoteDecoration: BoxDecoration(
        color: Colors.amber[900]!.withValues(alpha: 0.06),
        border: Border(left: BorderSide(color: Colors.amber[800]!, width: 3)),
      ),
    );

    _aiBubbleDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      ),
      border: Border.all(color: Colors.amber[800]!.withValues(alpha: 0.08)),
    );

    _userBubbleDecorationMe = BoxDecoration(
      color: Colors.amber[800]!.withValues(alpha: 0.15),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(4),
      ),
      border: Border.all(
        color: Colors.amber[800]!.withValues(alpha: 0.2),
      ),
    );

    _userBubbleDecorationOther = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.05),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(18),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(4),
        bottomRight: Radius.circular(18),
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.06),
      ),
    );

    _inputAreaDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.02),
      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.04))),
    );

    _textFieldWrapperDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    );

    _typingIndicatorDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(18),
        bottomLeft: Radius.circular(18),
        bottomRight: Radius.circular(18),
      ),
      border: Border.all(color: Colors.amber[800]!.withValues(alpha: 0.08)),
    );
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _typingDotController?.dispose();
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

  String _formatTime(DateTime dt) {
    final hour = dt.toLocal().hour;
    final minute = dt.toLocal().minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$h:$minute $period';
  }

  String _getSenderLabel(String senderId) {
    if (senderId == _currentUserId) return 'You';
    if (senderId == _aiAgentId) return 'TabL AI';
    // Truncate UUID for other users
    return 'User ${senderId.substring(0, 6)}';
  }

  bool _isAiMessage(RoomMessage message) => message.senderId == _aiAgentId;
  bool _isMyMessage(RoomMessage message) => message.senderId == _currentUserId;

  @override
  Widget build(BuildContext context) {
    final bool isOwner = widget.room.ownerId == _currentUserId;
    final bool isAiRoom = widget.room.type == RoomType.ai;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.8,
            colors: [
              (isAiRoom ? Colors.amber[900]! : Colors.teal[900]!).withOpacity(0.06),
              const Color(0xFF0A0A0C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, isOwner),
              Expanded(
                child: BlocConsumer<RoomChatBloc, RoomChatState>(
                  listener: (context, state) {
                    if (state is RoomChatLoaded) {
                      _scrollToBottom();
                    }
                  },
                  builder: (context, state) {
                    if (state is RoomChatLoading) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 32, height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text('Loading messages...', style: TextStyle(color: Colors.white.withOpacity(0.3), fontFamily: 'Inter', fontSize: 13)),
                          ],
                        ),
                      );
                    } else if (state is RoomChatLoaded) {
                      if (state.messages.isEmpty && !state.isAiTyping) {
                        return _buildEmptyState();
                      }
                      return _buildMessageList(state);
                    } else if (state is RoomChatError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 48),
                              const SizedBox(height: 16),
                              Text(state.message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontFamily: 'Inter')),
                            ],
                          ),
                        ),
                      );
                    }
                    return _buildEmptyState();
                  },
                ),
              ),
              if (widget.room.status == RoomStatus.open)
                _buildInputArea(context)
              else
                _buildConcludedBanner(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Bar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context, bool isOwner) {
    final isAiRoom = widget.room.type == RoomType.ai;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: isAiRoom
                    ? [Colors.amber[800]!, Colors.orange[900]!]
                    : [Colors.teal[600]!, Colors.teal[800]!],
              ),
            ),
            child: Icon(
              isAiRoom ? Icons.auto_awesome : (widget.room.type == RoomType.thread ? Icons.groups_outlined : Icons.person_outline),
              color: Colors.white, size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedOpacity(
                  opacity: _appBarTitleOpacity,
                  duration: Duration.zero, // controlled smoothly by state ticks
                  child: Text(
                    _displayedRoomName,
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: widget.room.status == RoomStatus.open ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.room.type.name.toUpperCase()} • ${widget.room.status == RoomStatus.open ? 'Active' : 'Concluded'}',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.4), letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.room.type == RoomType.private && isOwner)
            IconButton(
              icon: const Icon(Icons.public, color: Colors.blue, size: 20),
              tooltip: 'Convert to Public Thread',
              onPressed: () => _showConvertDialog(context),
            ),
          if (widget.room.status == RoomStatus.open && isOwner)
            IconButton(
              icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              tooltip: 'Conclude Discussion',
              onPressed: () => _showConcludeDialog(context),
            ),
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.amber, size: 20),
            tooltip: 'Invite Members',
            onPressed: () => _showInviteMembersBottomSheet(context),
          ),
        ],
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final isAiRoom = widget.room.type == RoomType.ai;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isAiRoom ? Colors.amber[800]! : Colors.teal).withOpacity(0.08),
                border: Border.all(color: (isAiRoom ? Colors.amber[800]! : Colors.teal).withOpacity(0.15)),
              ),
              child: Icon(
                isAiRoom ? Icons.auto_awesome : Icons.chat_bubble_outline,
                size: 40,
                color: isAiRoom ? Colors.amber[800] : Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isAiRoom ? 'Start collaborating with AI' : 'Start the conversation',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              isAiRoom
                  ? 'Ask a question or share an idea.\nTabL AI will respond with insights.'
                  : 'Send the first message to get the\ndiscussion going.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.3), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Message List ──────────────────────────────────────────────────────────

  Widget _buildMessageList(RoomChatLoaded state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: state.messages.length + (state.isAiTyping ? 1 : 0),
      itemBuilder: (context, index) {
        // AI typing indicator at the end
        if (index == state.messages.length && state.isAiTyping) {
          return _buildAiTypingIndicator();
        }

        final message = state.messages[index];
        final bool showSender = index == 0 ||
            state.messages[index - 1].senderId != message.senderId;

        if (message.isProposal) {
          return ProposalCard(
            message: message,
            onApprove: () => context.read<RoomChatBloc>().add(ApproveProposalRequested(message.id, widget.room.id)),
            onReject: () => context.read<RoomChatBloc>().add(RejectProposalRequested(message.id)),
          );
        }

        if (_isAiMessage(message)) {
          return _buildAiBubble(message, showSender);
        }
        return _buildUserBubble(message, showSender);
      },
    );
  }

  // ─── User Bubble ───────────────────────────────────────────────────────────

  Widget _buildUserBubble(RoomMessage message, bool showSender) {
    final bool isMe = _isMyMessage(message);
    return Padding(
      padding: EdgeInsets.only(bottom: showSender ? 12 : 4),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showSender)
            Padding(
              padding: EdgeInsets.only(left: isMe ? 0 : 4, right: isMe ? 4 : 0, bottom: 4),
              child: Text(
                _getSenderLabel(message.senderId),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isMe ? Colors.amber[600] : Colors.tealAccent.withOpacity(0.7),
                ),
              ),
            ),
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: GestureDetector(
              onLongPress: () => _showMessageActionSheet(
                context,
                message.content,
                isMe ? 'My Idea' : 'Member Idea',
              ),
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: isMe ? _userBubbleDecorationMe : _userBubbleDecorationOther,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.content,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14.5, color: Colors.white, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(message.createdAt),
                      style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.25)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── AI Bubble ─────────────────────────────────────────────────────────────

  Widget _buildAiBubble(RoomMessage message, bool showSender) {
    final parsed = _parseThinkContent(message.content);
    final String thinkingText = parsed['think']!;
    final String contentText = parsed['content']!;

    return Padding(
      padding: EdgeInsets.only(bottom: showSender ? 14 : 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSender)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Colors.amber[700]!, Colors.orange[800]!]),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TabL AI',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[600],
                    ),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onLongPress: () => _showMessageActionSheet(
              context,
              message.content,
              'TabL AI',
            ),
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
              padding: const EdgeInsets.all(16),
              decoration: _aiBubbleDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (thinkingText.isNotEmpty)
                    CollapsibleThinkingBlock(thinkingText: thinkingText),
                  MarkdownBody(
                    data: contentText,
                    styleSheet: _aiMarkdownStyleSheet,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(message.createdAt),
                    style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageActionSheet(BuildContext context, String content, String senderLabel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161618),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Message Options',
                style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.star_outline_rounded, color: Colors.amber),
                title: const Text('Save to Workspace Ledger', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 13.5)),
                subtitle: const Text('Bookmark this important discussion or idea', style: TextStyle(color: Colors.white30, fontSize: 11)),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await IdeasService.saveIdea(content, senderLabel);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.amber,
                      content: Text('Idea successfully saved to your Workspace Ledger!'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_rounded, color: Colors.tealAccent),
                title: const Text('Copy to Clipboard', style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 13.5)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Clipboard.setData(ClipboardData(text: content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.green,
                      content: Text('Message content copied to clipboard!'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ─── AI Typing Indicator ───────────────────────────────────────────────────

  Widget _buildAiTypingIndicator() {
    final controller = _typingDotController;
    if (controller == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [Colors.amber[700]!, Colors.orange[800]!]),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Text('TabL AI', style: TextStyle(fontFamily: 'Outfit', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amber[600])),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: _typingIndicatorDecoration,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final delay = i * 0.3;
                    final t = ((controller.value + delay) % 1.0);
                    final scale = 0.5 + 0.5 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8 * scale,
                      decoration: BoxDecoration(
                        color: Colors.amber[800]!.withOpacity(0.4 + 0.4 * scale),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── Concluded Banner ──────────────────────────────────────────────────────

  Widget _buildConcludedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green.withOpacity(0.5), size: 16),
          const SizedBox(width: 8),
          Text(
            'This discussion has concluded',
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.3), fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // ─── Input Area ────────────────────────────────────────────────────────────

  Widget _buildInputArea(BuildContext context) {
    final isAiRoom = widget.room.type == RoomType.ai;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: _inputAreaDecoration,
      child: Row(
        children: [
          if (!isAiRoom)
            IconButton(
              icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
              tooltip: 'Propose as Post',
              onPressed: () => _sendMessage(context, isProposal: true),
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: _textFieldWrapperDecoration,
              child: TextField(
                controller: _messageController,
                style: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: isAiRoom ? 'Ask TabL AI...' : 'Type a message...',
                  hintStyle: TextStyle(fontFamily: 'Inter', color: Colors.white.withOpacity(0.2), fontSize: 13.5),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _sendMessage(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.amber[700]!, Colors.amber[900]!],
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              onPressed: () => _sendMessage(context),
              padding: EdgeInsets.zero,
            ),
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
      roomType: widget.room.type.name,
    ));

    _messageController.clear();
  }

  // ─── Dialogs ───────────────────────────────────────────────────────────────

  void _showConcludeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Conclude Discussion', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
        content: const Text('This will close the discussion and prevent further messages.', style: TextStyle(color: Colors.white70, fontFamily: 'Inter')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context);
              final roomsBloc = context.read<RoomsBloc>();
              final roomRepo = RepositoryProvider.of<RoomRepository>(context);
              await roomRepo.concludeRoom(widget.room.id);
              if (mounted) {
                navigator.pop();
                roomsBloc.add(LoadMyRooms());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Conclude', style: TextStyle(fontFamily: 'Inter')),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Convert to Public Thread', style: TextStyle(color: Colors.white, fontFamily: 'Outfit')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter a name for this public thread:', style: TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
              decoration: InputDecoration(
                hintText: 'Thread name...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(fontFamily: 'Inter'))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final navigator = Navigator.of(context);
              final roomsBloc = context.read<RoomsBloc>();
              final roomRepo = RepositoryProvider.of<RoomRepository>(context);
              await roomRepo.convertToPublicThread(widget.room.id, controller.text);
              if (mounted) {
                navigator.pop();
                roomsBloc.add(LoadMyRooms());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: const Text('Make Public', style: TextStyle(fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }

  void _showInviteMembersBottomSheet(BuildContext context) {
    final isPublic = widget.room.isPublic || widget.room.type == RoomType.thread;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161618),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _InviteMembersSheetContent(roomId: widget.room.id, isPublic: isPublic);
      },
    );
  }

  Map<String, String> _parseThinkContent(String content) {
    final thinkRegex = RegExp(r'<think>([\s\S]*?)</think>');
    final match = thinkRegex.firstMatch(content);
    if (match != null) {
      final thinkText = match.group(1)?.trim() ?? '';
      final remainingContent = content.replaceFirst(thinkRegex, '').trim();
      return {
        'think': thinkText,
        'content': remainingContent,
      };
    }
    return {
      'think': '',
      'content': content,
    };
  }
}

class CollapsibleThinkingBlock extends StatefulWidget {
  final String thinkingText;
  const CollapsibleThinkingBlock({super.key, required this.thinkingText});

  @override
  State<CollapsibleThinkingBlock> createState() => _CollapsibleThinkingBlockState();
}

class _CollapsibleThinkingBlockState extends State<CollapsibleThinkingBlock> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology_outlined, size: 16, color: Colors.amber[500]),
                      const SizedBox(width: 8),
                      Text(
                        'Thinking Process',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14, top: 4),
              child: Text(
                widget.thinkingText,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withValues(alpha: 0.45),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InviteMembersSheetContent extends StatefulWidget {
  final String roomId;
  final bool isPublic;

  const _InviteMembersSheetContent({required this.roomId, required this.isPublic});

  @override
  State<_InviteMembersSheetContent> createState() => _InviteMembersSheetContentState();
}

class _InviteMembersSheetContentState extends State<_InviteMembersSheetContent> {
  final SupabaseClient _client = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  bool _isLoadingMembers = true;
  bool _isSearching = false;
  List<Map<String, dynamic>> _currentMembers = [];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final data = await _client
          .from('room_members')
          .select('role, profiles(id, full_name, email, avatar_url)')
          .eq('room_id', widget.roomId);

      setState(() {
        _currentMembers = List<Map<String, dynamic>>.from(data as List);
        _isLoadingMembers = false;
      });
    } catch (e) {
      print('[_InviteMembersSheetContent] Load members failed: $e');
      setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final currentUserId = _client.auth.currentUser?.id;
      var usersQuery = _client
          .from('profiles')
          .select()
          .or('full_name.ilike.%$query%,email.ilike.%$query%');

      if (currentUserId != null) {
        usersQuery = usersQuery.neq('id', currentUserId);
      }

      final data = await usersQuery.limit(10);

      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(data as List);
        _isSearching = false;
      });
    } catch (e) {
      print('[_InviteMembersSheetContent] Search failed: $e');
      setState(() => _isSearching = false);
    }
  }

  Future<void> _inviteUser(String targetUserId) async {
    try {
      // Check if user is already a member
      final alreadyMember = _currentMembers.any((m) {
        final profile = m['profiles'] as Map?;
        return profile != null && profile['id'] == targetUserId;
      });

      if (alreadyMember) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.amber,
            content: Text('User is already a member of this discussion room.'),
          ),
        );
        return;
      }

      await _client.from('room_members').insert({
        'room_id': widget.roomId,
        'profile_id': targetUserId,
        'role': 'member',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Successfully added member to the discussion room!'),
        ),
      );

      _searchController.clear();
      setState(() {
        _searchResults = [];
      });

      // Reload
      _loadCurrentMembers();
    } catch (e) {
      print('[_InviteMembersSheetContent] Invite failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Failed to invite member: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 20.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
      ),
      child: MainModalLayout(
        roomId: widget.roomId,
        isPublic: widget.isPublic,
        isLoadingMembers: _isLoadingMembers,
        currentMembers: _currentMembers,
        isSearching: _isSearching,
        searchResults: _searchResults,
        searchController: _searchController,
        onSearchChanged: _searchUsers,
        onInvitePressed: _inviteUser,
      ),
    );
  }
}

class MainModalLayout extends StatelessWidget {
  final String roomId;
  final bool isPublic;
  final bool isLoadingMembers;
  final List<Map<String, dynamic>> currentMembers;
  final bool isSearching;
  final List<Map<String, dynamic>> searchResults;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onInvitePressed;

  const MainModalLayout({
    super.key,
    required this.roomId,
    required this.isPublic,
    required this.isLoadingMembers,
    required this.currentMembers,
    required this.isSearching,
    required this.searchResults,
    required this.searchController,
    required this.onSearchChanged,
    required this.onInvitePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pill Accent Indicator
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 18),

        const Text(
          'Manage Members & Share',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),

        // Public Share Link Card
        if (isPublic) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber[800]!.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber[800]!.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Public Thread Link',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'https://tabl.app/thread/$roomId',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: 'https://tabl.app/thread/$roomId'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Copied shareable discussion link to clipboard!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[800],
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Copy', style: TextStyle(fontFamily: 'Outfit', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Live Search Input Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Invite others by full name or email...',
              hintStyle: TextStyle(color: Colors.white24, fontSize: 12.5),
              prefixIcon: Icon(Icons.person_add_alt_outlined, color: Colors.white30, size: 18),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Search Results List
        if (searchResults.isNotEmpty) ...[
          const Text(
            'Search Results',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          const SizedBox(height: 6),
          Container(
            constraints: const BoxConstraints(maxHeight: 160),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final user = searchResults[index];
                final name = user['full_name'] ?? 'Anonymous';
                final email = user['email'] ?? '';
                final avatar = user['avatar_url'] as String?;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white10,
                    backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null ? const Icon(Icons.person, size: 14, color: Colors.white54) : null,
                  ),
                  title: Text(name, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(email, style: const TextStyle(color: Colors.white38, fontFamily: 'Inter', fontSize: 11)),
                  trailing: TextButton(
                    onPressed: () => onInvitePressed(user['id']),
                    style: TextButton.styleFrom(foregroundColor: Colors.amber),
                    child: const Text('Add', style: TextStyle(fontFamily: 'Outfit', fontSize: 12.5, fontWeight: FontWeight.bold)),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white10, height: 20),
        ],

        // Members List Title
        const Text(
          'Active Group Members',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 8),

        // Current Members List
        if (isLoadingMembers)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(child: CircularProgressIndicator(color: Colors.amber)),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currentMembers.length,
              itemBuilder: (context, index) {
                final m = currentMembers[index];
                final role = m['role'] ?? 'member';
                final profile = m['profiles'] as Map?;
                final name = profile?['full_name'] ?? 'Anonymous User';
                final email = profile?['email'] ?? '';
                final avatar = profile?['avatar_url'] as String?;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white10,
                    backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                    child: avatar == null ? const Icon(Icons.person, size: 14, color: Colors.white54) : null,
                  ),
                  title: Text(name, style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold)),
                  subtitle: Text(email, style: const TextStyle(color: Colors.white38, fontFamily: 'Inter', fontSize: 11)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: role == 'owner' ? Colors.teal.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                    ),
                    child: Text(
                      role.toString().toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: role == 'owner' ? Colors.tealAccent : Colors.white54,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
