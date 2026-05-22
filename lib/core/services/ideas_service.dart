import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SavedIdea {
  final String id;
  final String content;
  final String source; // e.g. 'KrishiBot', 'SalesBuddy', 'Discussion Thread'
  final DateTime savedAt;

  SavedIdea({
    required this.id,
    required this.content,
    required this.source,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'source': source,
        'savedAt': savedAt.toIso8601String(),
      };

  factory SavedIdea.fromJson(Map<String, dynamic> json) => SavedIdea(
        id: json['id'],
        content: json['content'],
        source: json['source'] ?? 'General',
        savedAt: DateTime.parse(json['savedAt']),
      );
}

class IdeasService {
  static const String _key = 'saved_workspace_ideas';

  static Future<List<SavedIdea>> getIdeas() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((item) => SavedIdea.fromJson(jsonDecode(item))).toList();
  }

  static Future<void> saveIdea(String content, String source) async {
    final prefs = await SharedPreferences.getInstance();
    final ideas = await getIdeas();
    
    // Prevent duplicate content saves
    if (ideas.any((item) => item.content.trim() == content.trim())) {
      return;
    }

    final newIdea = SavedIdea(
      id: 'idea_${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      source: source,
      savedAt: DateTime.now(),
    );

    ideas.insert(0, newIdea);
    final list = ideas.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, list);
  }

  static Future<void> deleteIdea(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final ideas = await getIdeas();
    ideas.removeWhere((item) => item.id == id);
    final list = ideas.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, list);
  }
}
