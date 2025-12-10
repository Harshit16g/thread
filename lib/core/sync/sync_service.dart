import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _pendingPrefsKey = 'pending_preferences';
  
  // 7 days in milliseconds
  static const int _syncInterval = 7 * 24 * 60 * 60 * 1000;

  final SupabaseClient _supabaseClient;

  SyncService(this._supabaseClient);

  /// Updates a preference locally and marks it for sync.
  Future<void> updatePreference(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing pending prefs
    final String? pendingJson = prefs.getString(_pendingPrefsKey);
    Map<String, dynamic> pendingMap = {};
    if (pendingJson != null) {
      try {
        pendingMap = json.decode(pendingJson);
      } catch (e) {
        debugPrint('Error decoding pending prefs: $e');
      }
    }

    // Update with new value
    pendingMap[key] = value;

    // Save back to local storage
    await prefs.setString(_pendingPrefsKey, json.encode(pendingMap));
    debugPrint('Preference buffered: $key = $value');
  }

  /// Checks if sync is needed (every 7 days) and performs it if so.
  Future<void> checkAndSync() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    final prefs = await SharedPreferences.getInstance();
    final int? lastSync = prefs.getInt(_lastSyncKey);
    final int now = DateTime.now().millisecondsSinceEpoch;

    if (lastSync == null || (now - lastSync) > _syncInterval) {
      debugPrint('Sync interval reached. Syncing preferences...');
      await forceSync();
    } else {
      debugPrint('Sync not needed yet. Last sync: ${DateTime.fromMillisecondsSinceEpoch(lastSync)}');
    }
  }

  /// Forces a sync of all pending preferences to Supabase.
  Future<void> forceSync() async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      debugPrint('Cannot sync: No user logged in.');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String? pendingJson = prefs.getString(_pendingPrefsKey);
    
    if (pendingJson == null) {
      debugPrint('No pending preferences to sync.');
      return;
    }

    try {
      final Map<String, dynamic> pendingMap = json.decode(pendingJson);
      if (pendingMap.isEmpty) return;

      // Map local keys to Supabase column names if necessary
      // For now assuming keys match column names or are mapped here
      final Map<String, dynamic> updateData = {};
      
      if (pendingMap.containsKey('theme')) {
        updateData['theme_preference'] = pendingMap['theme'];
      }
      
      // Add other categories here as needed

      if (updateData.isNotEmpty) {
        await _supabaseClient.from('profiles').update(updateData).eq('id', user.id);
        debugPrint('Successfully synced preferences to Supabase.');
      }

      // Clear pending changes after successful sync
      await prefs.remove(_pendingPrefsKey);
      
      // Update last sync timestamp
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);

    } catch (e) {
      debugPrint('Failed to sync preferences: $e');
      // Keep pending changes to try again later
    }
  }

  /// Clears local pending state (e.g. on logout if desired, though usually we sync before logout)
  Future<void> clearLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingPrefsKey);
    await prefs.remove(_lastSyncKey);
  }
}
