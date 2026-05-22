import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/ai_repository.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/events/ai_chat_event.dart';
import '../bloc/states/ai_chat_state.dart';
import '../../domain/entities/chat_message.dart';

class AiAssistantDetailScreen extends StatefulWidget {
  final String botId;
  final String botName;
  final String botEmoji;
  final Color botColor;
  final int initialTabIndex;

  const AiAssistantDetailScreen({
    super.key,
    required this.botId,
    required this.botName,
    required this.botEmoji,
    required this.botColor,
    this.initialTabIndex = 0,
  });

  @override
  State<AiAssistantDetailScreen> createState() => _AiAssistantDetailScreenState();
}

class _AiAssistantDetailScreenState extends State<AiAssistantDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SupabaseClient _client = Supabase.instance.client;

  bool _isDbLoading = false;
  List<Map<String, dynamic>> _localbookData = [];
  List<Map<String, dynamic>> _salesbuddyData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _loadDatabaseInsights();
      }
    });

    if (widget.initialTabIndex == 1) {
      _loadDatabaseInsights();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadDatabaseInsights() async {
    setState(() => _isDbLoading = true);
    try {
      if (widget.botId == 'localbook') {
        final data = await _client.from('localbook_transactions').select().order('created_at', ascending: false);
        setState(() {
          _localbookData = List<Map<String, dynamic>>.from(data as List);
        });
      } else if (widget.botId == 'salesbuddy') {
        // Retrieve sales or inventory mock logs
        final data = await _client.from('salesbuddy_inventory').select();
        setState(() {
          _salesbuddyData = List<Map<String, dynamic>>.from(data as List);
        });
      }
    } catch (e) {
      print('[AiAssistantDetailScreen] Database insights load exception: $e');
    } finally {
      if (mounted) setState(() => _isDbLoading = false);
    }
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
    return BlocProvider(
      create: (context) => AiChatBloc(
        aiRepository: RepositoryProvider.of<AiRepository>(context),
      ),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F0F11),
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white70),
              title: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.botColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Text(widget.botEmoji, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.botName,
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6, height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Active Bot',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: Colors.white38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: widget.botColor,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white38,
                labelStyle: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Chat Assist'),
                  Tab(text: 'Database Insights'),
                ],
              ),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    widget.botColor.withValues(alpha: 0.05),
                    const Color(0xFF0F0F11),
                  ],
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildChatTab(context),
                  _buildInsightsTab(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── CHAT TAB VIEW ──────────────────────────────────────────────────────────

  Widget _buildChatTab(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocConsumer<AiChatBloc, AiChatState>(
            listener: (context, state) {
              _scrollToBottom();
            },
            builder: (context, state) {
              final messages = state.messages;

              if (messages.isEmpty) {
                return _buildChatWelcomeState(context);
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.role == 'user';

                  return _buildMessageBubble(msg, isUser);
                },
              );
            },
          ),
        ),

        // AI Thinking Status indicator
        BlocBuilder<AiChatBloc, AiChatState>(
          builder: (context, state) {
            if (state.isStreaming) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.botColor),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${widget.botName} is typing...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        _buildChatInputArea(context),
      ],
    );
  }

  Widget _buildChatWelcomeState(BuildContext context) {
    String starterPrompt = "";
    if (widget.botId == 'krishibot') {
      starterPrompt = "Suggest NPK fertilizer ratios for growing high yield Rabi Wheat.";
    } else if (widget.botId == 'medguide') {
      starterPrompt = "What are the first-aid steps for minor fire burns on hands?";
    } else if (widget.botId == 'salesbuddy') {
      starterPrompt = "Show current inventory levels and log a sale of 5 bags of seeds.";
    } else if (widget.botId == 'localbook') {
      starterPrompt = "Record a direct cash expense of 1200 rupees for field irrigation.";
    } else if (widget.botId == 'tutorbot') {
      starterPrompt = "Explain the formula and balanced equations of Photosynthesis.";
    } else {
      starterPrompt = "Translate 'Organic grains are harvested successfully today' to Hindi.";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.botColor.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(widget.botEmoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Hi, I am ${widget.botName}!',
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation below or try this customized starter command:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.4),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Starter Prompt Card
          InkWell(
            onTap: () {
              _messageController.text = starterPrompt;
              _sendMessage(context);
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.botColor.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: widget.botColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      starterPrompt,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.all(14.0),
        decoration: BoxDecoration(
          color: isUser 
              ? widget.botColor.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser 
                ? widget.botColor.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Think / Reasoning collapse block for DeepSeek reasoning tags if available!
            if (!isUser && msg.reasoning != null && msg.reasoning!.trim().isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.psychology_outlined, size: 14, color: widget.botColor),
                        const SizedBox(width: 6),
                        Text(
                          'Bot Thinking Process',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.botColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      msg.reasoning!,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.35),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            MarkdownBody(
              data: msg.content,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Inter',
                  fontSize: 13.5,
                  height: 1.45,
                ),
                strong: TextStyle(
                  color: widget.botColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
                tableBody: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Inter',
                  fontSize: 12,
                ),
                tableHead: TextStyle(
                  color: widget.botColor,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
                tableBorder: TableBorder.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInputArea(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0C),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
              ),
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(color: Colors.white, fontFamily: 'Inter', fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Talk to ${widget.botName}...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.botColor,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              onPressed: () => _sendMessage(context),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    FocusScope.of(context).unfocus();

    // Trigger AI Bloc specifying this botId as the active role prompt!
    context.read<AiChatBloc>().add(
      AiChatMessageSent(message: text, role: widget.botId),
    );
  }

  // ─── DATABASE INSIGHTS TAB VIEW ─────────────────────────────────────────────

  Widget _buildInsightsTab() {
    if (_isDbLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.amber));
    }

    if (widget.botId == 'localbook') {
      return _buildLocalBookInsights();
    } else if (widget.botId == 'salesbuddy') {
      return _buildSalesBuddyInsights();
    } else if (widget.botId == 'krishibot') {
      return _buildKrishiBotInsights();
    } else if (widget.botId == 'medguide') {
      return _buildMedGuideInsights();
    } else {
      return _buildGenericBotInsights();
    }
  }

  Widget _buildLocalBookInsights() {
    final transactions = _localbookData.isEmpty ? _getMockTransactions() : _localbookData;
    
    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (var tx in transactions) {
      final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
      if (tx['type'] == 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    }
    final netBalance = totalIncome - totalExpense;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3 Metric Grid Cards
          Row(
            children: [
              Expanded(
                child: _buildInsightMetricCard(
                  title: 'Income',
                  val: '₹${totalIncome.toStringAsFixed(0)}',
                  color: Colors.green,
                  icon: Icons.arrow_upward_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInsightMetricCard(
                  title: 'Expenses',
                  val: '₹${totalExpense.toStringAsFixed(0)}',
                  color: Colors.red,
                  icon: Icons.arrow_downward_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInsightMetricCard(
            title: 'Net Margin Balance',
            val: '₹${netBalance.toStringAsFixed(2)}',
            color: netBalance >= 0 ? Colors.tealAccent : Colors.redAccent,
            icon: Icons.account_balance_wallet_outlined,
            isFullWidth: true,
          ),
          const SizedBox(height: 24),

          // Ledger Table Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Cash Flow Logs',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white30, size: 18),
                onPressed: _loadDatabaseInsights,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Cash Flow Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.03)),
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final isIncome = tx['type'] == 'income';
                final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
                final category = tx['category'] ?? 'Other';
                final notes = tx['notes'] ?? '';
                final date = _formatDate(tx['created_at']?.toString() ?? '');

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    child: Icon(
                      isIncome ? Icons.north_east : Icons.south_west,
                      color: isIncome ? Colors.green : Colors.red,
                      size: 16,
                    ),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.toString().toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        '${isIncome ? "+" : "-"} ₹${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isIncome ? Colors.green : Colors.red,
                          fontFamily: 'Outfit',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notes.isNotEmpty ? notes : 'Logged transaction',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontFamily: 'Inter', fontSize: 11),
                          ),
                        ),
                        Text(
                          date,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontFamily: 'Inter', fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesBuddyInsights() {
    final inventory = _salesbuddyData.isEmpty ? _getMockInventory() : _salesbuddyData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Retail Stock Inventory',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white30, size: 18),
                onPressed: _loadDatabaseInsights,
              ),
            ],
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: inventory.length,
            itemBuilder: (context, index) {
              final item = inventory[index];
              final name = item['item_name'] ?? 'Product';
              final stock = int.tryParse(item['stock_quantity']?.toString() ?? '0') ?? 0;
              final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
              final unit = item['unit'] ?? 'bags';

              final isLowStock = stock <= 10;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: isLowStock ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                          ),
                          child: Text(
                            isLowStock ? 'Stock Low' : 'In Stock',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: isLowStock ? Colors.red : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Price: ₹${price.toStringAsFixed(0)} per $unit',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontFamily: 'Inter', fontSize: 12),
                        ),
                        Text(
                          '$stock $unit remaining',
                          style: const TextStyle(color: Colors.white70, fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Stock Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (stock / 100).clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: AlwaysStoppedAnimation<Color>(isLowStock ? Colors.red : Colors.blue),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKrishiBotInsights() {
    final guides = [
      {
        'title': 'Yellow stripe rust diagnostics',
        'crop': 'Wheat crop',
        'treatment': 'Spray Propiconazole 25 EC @ 0.1% directly.',
        'icon': '🌾'
      },
      {
        'title': 'Optimum NPK ratio guidelines',
        'crop': 'Grains / Paddy field',
        'treatment': 'Apply NPK in a strict 120:60:40 standard ratio.',
        'icon': '🌱'
      },
      {
        'title': 'Paddy field tillering irrigation',
        'crop': 'Rice / Paddy',
        'treatment': 'Maintain standing water level of 2-5 cm post sowing.',
        'icon': '💧'
      }
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farming Diagnostics Directory',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: guides.length,
            itemBuilder: (context, index) {
              final guide = guides[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(guide['icon']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide['title']!,
                            style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Crop Category: ${guide['crop']}',
                            style: TextStyle(color: widget.botColor, fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            guide['treatment']!,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontFamily: 'Inter', fontSize: 12, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMedGuideInsights() {
    final list = [
      {
        'symptom': 'Cuts & Bleeding Wounds',
        'first_aid': 'Apply direct firm pressure with a clean cloth. Elevate the cut above heart level.',
        'desc': 'Clean gently with fresh water and wrap loose gauze.',
      },
      {
        'symptom': 'Heat Stroke Symptoms',
        'first_aid': 'Move the patient to shade immediately. Cooling sprays or wet sheets over body.',
        'desc': 'Rehydrate patient with cool electrolyte water.',
      },
      {
        'symptom': 'Minor Fire Burns',
        'first_aid': 'Run cool water over the burn for 10-15 mins. Loose sterile wrap.',
        'desc': 'Do NOT apply ice, oil, butter, or pop blisters.',
      }
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Emergency First-Aid Manual',
            style: TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final first = list[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.healing_outlined, color: Colors.redAccent, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          first['symptom']!,
                          style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Primary Action: ${first['first_aid']}',
                      style: const TextStyle(color: Colors.white70, fontFamily: 'Inter', fontSize: 12, height: 1.35),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Notes: ${first['desc']}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontFamily: 'Inter', fontSize: 11),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGenericBotInsights() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: widget.botColor.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              '${widget.botName} Insight Log',
              style: const TextStyle(fontFamily: 'Outfit', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Any actions logged or tools triggered by ${widget.botName} will be recorded and visually presented inside this database log.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, color: Colors.white.withValues(alpha: 0.35), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightMetricCard({
    required String title,
    required String val,
    required Color color,
    required IconData icon,
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontFamily: 'Inter', fontSize: 11),
              ),
              const SizedBox(height: 4),
              Text(
                val,
                style: const TextStyle(color: Colors.white, fontFamily: 'Outfit', fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return 'Today';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'Recent';
    }
  }

  List<Map<String, dynamic>> _getMockTransactions() {
    return [
      {
        'amount': 3500.0,
        'type': 'income',
        'category': 'Sales',
        'notes': 'Sold organic fertilizer harvest bags',
        'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'amount': 1200.0,
        'type': 'expense',
        'category': 'Fertilizers',
        'notes': 'Bought high yield urea fertilizer bags',
        'created_at': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      },
      {
        'amount': 1500.0,
        'type': 'expense',
        'category': 'Water',
        'notes': 'Paid pump irrigation service charge',
        'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      },
    ];
  }

  List<Map<String, dynamic>> _getMockInventory() {
    return [
      {
        'item_name': 'Organic fertilizer seeds',
        'stock_quantity': 45,
        'price': 350.0,
        'unit': 'bags',
      },
      {
        'item_name': 'Rabi high-yield wheat seeds',
        'stock_quantity': 8,
        'price': 400.0,
        'unit': 'bags',
      },
      {
        'item_name': 'Yellow Stripe pest pesticide',
        'stock_quantity': 60,
        'price': 220.0,
        'unit': 'bottles',
      },
    ];
  }
}
