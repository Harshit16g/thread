import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/events/ai_chat_event.dart';
import '../bloc/states/ai_chat_state.dart';
import '../../domain/entities/chat_message.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _micGlowController;
  late Animation<double> _micGlowAnimation;
  
  bool _isListening = false;
  String _activeRole = 'partner'; // 'partner' | 'employee' | 'customer'

  // Suggested starter prompts per TabL module
  final Map<String, Map<String, String>> _moduleSuggestions = {
    'KrishiBot': {
      'icon': '🌾',
      'label': 'KrishiBot',
      'prompt': 'Suggest pesticide or fertilizer for Yellow Rust in wheat crop',
    },
    'LocalBook': {
      'icon': '📊',
      'label': 'LocalBook',
      'prompt': 'Add an expense transaction of 1500 rupees for organic fertilizer seeds',
    },
    'MedGuide': {
      'icon': '🩺',
      'label': 'MedGuide',
      'prompt': 'Explain the first-aid treatment steps for heat stroke symptoms',
    },
    'TutorBot': {
      'icon': '📚',
      'label': 'TutorBot',
      'prompt': 'Explain the formula of photosynthesis in science with equations',
    },
    'LangBridge': {
      'icon': '🗣️',
      'label': 'LangBridge',
      'prompt': 'Translate "Please irrigate the paddy field today evening" into Hindi',
    },
    'SalesBuddy': {
      'icon': '💰',
      'label': 'SalesBuddy',
      'prompt': 'Log a sale of 10 organic fertilizer bags at 350 rupees each in my ledger',
    },
  };

  @override
  void initState() {
    super.initState();
    
    // Voice glowing pulsing animation
    _micGlowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1500),
    );
    _micGlowAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(
        parent: _micGlowController,
        curve: Curves.easeInOut,
      ),
    );
    
    _micGlowController.duration = const Duration(milliseconds: 1000);
    _micGlowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _micGlowController.dispose();
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

  void _simulateVoiceInput() {
    setState(() {
      _isListening = true;
    });

    // Simulate speech-to-text typing delays
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        // Insert a beautiful contextual voice command
        _messageController.text =
            "I sold 5 bags of organic fertilizer for 350 rupees each. Log this sale in SalesBuddy inventory!";
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.amber[900]?.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
          content: const Row(
            children: [
              Icon(Icons.mic, color: Colors.white),
              SizedBox(width: 12),
              Text(
                'Speech translated successfully!',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiChatBloc, AiChatState>(
      listener: (context, state) {
        _scrollToBottom();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F11),
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topRight,
              radius: 1.5,
              colors: [
                Colors.amber[900]!.withOpacity(0.08),
                const Color(0xFF0F0F11),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildModuleSuggestionsTray(),
                Expanded(
                  child: _buildChatArea(),
                ),
                _buildVoiceListeningSimulator(),
                _buildBottomInputArea(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.amber[800],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber[800]!.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TabL AI',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Intelligent Business Assistant',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              // Role picker glass dropdown button
              _buildRoleChip(),
              const SizedBox(width: 8),
              // Clear History
              IconButton(
                icon: Icon(Icons.delete_sweep_outlined, color: Colors.white.withOpacity(0.6)),
                tooltip: 'Clear Conversation',
                onPressed: () {
                  context.read<AiChatBloc>().add(const AiChatClearHistory());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white.withOpacity(0.08),
                      behavior: SnackBarBehavior.floating,
                      content: const Text(
                        'Chat history cleared.',
                        style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip() {
    final Map<String, Map<String, dynamic>> roleDetails = {
      'partner': {'icon': Icons.business_center_outlined, 'label': 'Partner', 'color': Colors.amber[800]},
      'employee': {'icon': Icons.engineering_outlined, 'label': 'Worker', 'color': Colors.tealAccent},
      'customer': {'icon': Icons.person_search_outlined, 'label': 'User', 'color': Colors.lightBlueAccent},
    };

    final current = roleDetails[_activeRole]!;

    return PopupMenuButton<String>(
      onSelected: (String role) {
        setState(() {
          _activeRole = role;
        });
        context.read<AiChatBloc>().add(AiChatUpdateRole(role));
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'partner',
          child: Row(
            children: [
              Icon(Icons.business_center, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text('Business Partner', style: TextStyle(fontFamily: 'Inter')),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'employee',
          child: Row(
            children: [
              Icon(Icons.engineering, color: Colors.tealAccent, size: 18),
              SizedBox(width: 8),
              Text('Field Worker', style: TextStyle(fontFamily: 'Inter')),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'customer',
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.lightBlueAccent, size: 18),
              SizedBox(width: 8),
              Text('App User', style: TextStyle(fontFamily: 'Inter')),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              current['icon'] as IconData,
              size: 14,
              color: current['color'] as Color,
            ),
            const SizedBox(width: 6),
            Text(
              current['label'] as String,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 14, color: Colors.white.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleSuggestionsTray() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        children: _moduleSuggestions.entries.map((entry) {
          final moduleName = entry.key;
          final details = entry.value;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                setState(() {
                  _messageController.text = details['prompt']!;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.white.withOpacity(0.06),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    content: Text(
                      'Prompt helper loaded for $moduleName.',
                      style: const TextStyle(color: Colors.white, fontFamily: 'Inter'),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      details['icon']!,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      details['label']!,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChatArea() {
    return BlocBuilder<AiChatBloc, AiChatState>(
      builder: (context, state) {
        if (state.messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: state.messages.length + (state.isStreaming && state.messages.last.role == 'user' ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.messages.length) {
              // Show thinking bubble when stream starts but assistant message hasn't been emitted yet
              return _buildThinkingPlaceholder();
            }

            final message = state.messages[index];
            if (message.role == 'user') {
              return _buildUserBubble(message);
            } else {
              return _buildAssistantBubble(message);
            }
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber[800]!.withOpacity(0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.amber[800]!.withOpacity(0.2), width: 2),
              ),
              child: Icon(
                Icons.spatial_audio_off_outlined,
                size: 48,
                color: Colors.amber[800],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'How can I help you today?',
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a module tray above or ask a business question.\nTabL supports inventory management, sales tracking, and intelligent business insights.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white.withOpacity(0.4),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            _buildFeaturePromptCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturePromptCards() {
    final suggestions = [
      {'icon': '🌾', 'title': 'Business Growth', 'prompt': 'What strategies do you suggest for growing my retail business?'},
      {'icon': '📊', 'title': 'Financial Summary', 'prompt': 'Show me my recent transaction summary and cash flow'},
      {'icon': '💰', 'title': 'Inventory Management', 'prompt': 'Check current stock levels and log a new sale'},
    ];

    return Column(
      children: suggestions.map((card) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              setState(() {
                _messageController.text = card['prompt']!;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
              child: Row(
                children: [
                  Text(card['icon']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card['title']!,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card['prompt']!,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white.withOpacity(0.3)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildThinkingPlaceholder() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0, right: 48.0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Thinking...',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0, left: 48.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.amber[950]!.withOpacity(0.2),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          border: Border.all(
            color: Colors.amber[800]!.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(ChatMessage message) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0, right: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reasoning box if present
            if (message.reasoning != null) ...[
              _buildReasoningDrawer(message.reasoning!),
              const SizedBox(height: 12),
            ],
            
            // Tool queue queue if present
            if (message.toolQueue.isNotEmpty) ...[
              _buildToolQueueWidget(message.toolQueue),
              const SizedBox(height: 12),
            ],

            // Content markdown rendering
            if (message.content.isNotEmpty)
              MarkdownBody(
                data: message.content,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.5,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  tableBody: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                  tableHead: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber[800],
                  ),
                  tableBorder: TableBorder.all(
                    color: Colors.white.withOpacity(0.08),
                    width: 1,
                  ),
                  tableCellsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  listBullet: const TextStyle(color: Colors.amber, fontSize: 16),
                ),
              )
            else if (message.isStreaming)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Generating answer...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReasoningDrawer(String reasoning) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: ExpansionTile(
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          dense: true,
          iconColor: Colors.amber[800],
          collapsedIconColor: Colors.white38,
          title: Row(
            children: [
              Icon(Icons.psychology_outlined, size: 16, color: Colors.amber[800]),
              const SizedBox(width: 8),
              const Text(
                'TabL AI Thought Process',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Text(
                reasoning,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.4),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolQueueWidget(List<ToolTask> toolQueue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dns_outlined, color: Colors.amber[800], size: 14),
              const SizedBox(width: 6),
              Text(
                'Active Database Operations',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...toolQueue.map((task) {
            IconData statusIcon = Icons.sync;
            Color statusColor = Colors.amber;
            Widget leadingIndicator = SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
              ),
            );

            if (task.status == 'done') {
              statusIcon = Icons.check_circle_outline;
              statusColor = Colors.green;
              leadingIndicator = Icon(statusIcon, color: statusColor, size: 16);
            } else if (task.status == 'error') {
              statusIcon = Icons.warning_amber_outlined;
              statusColor = Colors.redAccent;
              leadingIndicator = Icon(statusIcon, color: statusColor, size: 16);
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  leadingIndicator,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: task.status == 'running' ? Colors.white60 : Colors.white38,
                        fontWeight: task.status == 'running' ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildVoiceListeningSimulator() {
    if (!_isListening) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber[900]!.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber[800]!.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                'TabL Voice Assistant',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[100],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(7, (index) {
              // Pulsing sound waves
              final heights = [10.0, 24.0, 16.0, 32.0, 12.0, 28.0, 8.0];
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 3.5,
                height: heights[index],
                decoration: BoxDecoration(
                  color: Colors.amber[800],
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Listening to your voice...',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputArea() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.01),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1.0,
          ),
        ),
      ),
      child: BlocBuilder<AiChatBloc, AiChatState>(
        builder: (context, state) {
          final isStreaming = state.isStreaming;

          return Row(
            children: [
              // Voice glowing mic button
              ScaleTransition(
                scale: _micGlowAnimation,
                child: FloatingActionButton.small(
                  heroTag: 'micBtn',
                  backgroundColor: _isListening ? Colors.redAccent : Colors.amber[800],
                  elevation: 6,
                  onPressed: isStreaming ? null : _simulateVoiceInput,
                  child: Icon(
                    _isListening ? Icons.stop : Icons.mic_none_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Text Field container
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty && !isStreaming) {
                        _sendMessage(context);
                      }
                    },
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type or talk to TabL...',
                      hintStyle: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white.withOpacity(0.2),
                        fontSize: 13.5,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              
              // Send Action
              IconButton(
                icon: isStreaming
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
                        ),
                      )
                    : Icon(
                        Icons.send_rounded,
                        color: _messageController.text.trim().isEmpty
                            ? Colors.white.withOpacity(0.2)
                            : Colors.amber[800],
                      ),
                onPressed: isStreaming || _messageController.text.trim().isEmpty
                    ? null
                    : () => _sendMessage(context),
              ),
            ],
          );
        },
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<AiChatBloc>().add(
          AiChatMessageSent(
            message: text,
            role: _activeRole,
          ),
        );
    
    setState(() {
      _messageController.clear();
    });
  }
}
