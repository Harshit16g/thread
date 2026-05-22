import 'package:flutter/material.dart';
import 'ai_assistant_detail_screen.dart';

class AiHubScreen extends StatelessWidget {
  const AiHubScreen({super.key});

  final List<Map<String, dynamic>> _bots = const [
    {
      'id': 'krishibot',
      'name': 'KrishiBot',
      'emoji': '🌾',
      'desc': 'Farming advisor for crop diseases, treatment advice, and fertilizer ratios.',
      'tag': 'Agriculture',
      'color': Colors.green,
      'tool': 'krishibot_get_advice',
      'insightsLabel': 'Crop Logs',
    },
    {
      'id': 'medguide',
      'name': 'MedGuide',
      'emoji': '🩺',
      'desc': 'Interactive healthcare support for first-aid procedures and symptoms check.',
      'tag': 'Medical Care',
      'color': Colors.red,
      'tool': 'medguide_get_first_aid',
      'insightsLabel': 'First-Aid list',
    },
    {
      'id': 'salesbuddy',
      'name': 'SalesBuddy',
      'emoji': '📦',
      'desc': 'Log daily customer sales, verify inventory quantities, and manage stock items.',
      'tag': 'Sales & Stock',
      'color': Colors.blue,
      'tool': 'salesbuddy_log_sale',
      'insightsLabel': 'Ledger & Stock',
    },
    {
      'id': 'localbook',
      'name': 'LocalBook',
      'emoji': '📊',
      'desc': 'Manage business cash flow, track expenses, and audit financial payments.',
      'tag': 'Finance Ledger',
      'color': Colors.amber,
      'tool': 'localbook_add_transaction',
      'insightsLabel': 'Cash flow ledger',
    },
    {
      'id': 'tutorbot',
      'name': 'TutorBot',
      'emoji': '📚',
      'desc': 'Education helper explaining math equations, physics formulas, and chemistry.',
      'tag': 'Academics',
      'color': Colors.purple,
      'tool': 'tutorbot_get_explanation',
      'insightsLabel': 'Explanation logs',
    },
    {
      'id': 'langbridge',
      'name': 'LangBridge',
      'emoji': '🗣️',
      'desc': 'Translate localized regional assets and conversation segments into Hindi, Tamil, etc.',
      'tag': 'Translations',
      'color': Colors.teal,
      'tool': 'langbridge_translate',
      'insightsLabel': 'Translations log',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.6,
            colors: [
              Colors.amber[900]!.withValues(alpha: 0.05),
              const Color(0xFF0A0A0C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Intelligence Hub',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select a specialized bot to chat and manage database insights',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),

              // Grid list
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: _bots.length,
                  itemBuilder: (context, index) {
                    final bot = _bots[index];
                    final Color botColor = bot['color'] as Color;

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: botColor.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (routeContext) => AiAssistantDetailScreen(
                                    botId: bot['id'],
                                    botName: bot['name'],
                                    botEmoji: bot['emoji'],
                                    botColor: botColor,
                                    initialTabIndex: 0,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Bot Avatar
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 38, height: 38,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: botColor.withValues(alpha: 0.15),
                                        ),
                                        child: Center(
                                          child: Text(
                                            bot['emoji'],
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: botColor.withValues(alpha: 0.08),
                                        ),
                                        child: Text(
                                          bot['tag'],
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: botColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  // Name
                                  Text(
                                    bot['name'],
                                    style: const TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),

                                  // Description
                                  Expanded(
                                    child: Text(
                                      bot['desc'],
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11.5,
                                        color: Colors.white.withValues(alpha: 0.4),
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Stored Database Insights Direct Button
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (routeContext) => AiAssistantDetailScreen(
                                            botId: bot['id'],
                                            botName: bot['name'],
                                            botEmoji: bot['emoji'],
                                            botColor: botColor,
                                            initialTabIndex: 1, // Open directly in insights view!
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white.withValues(alpha: 0.03),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.bar_chart_rounded, size: 11, color: botColor),
                                          const SizedBox(width: 4),
                                          Text(
                                            bot['insightsLabel'],
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white.withValues(alpha: 0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
