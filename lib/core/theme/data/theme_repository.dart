import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../sync/sync_service.dart';
import '../app_theme.dart';

class ThemeRepository {
  static const String _themeKey = 'app_theme';
  final SyncService _syncService;
  final SupabaseClient _supabase;

  ThemeRepository({SyncService? syncService, SupabaseClient? supabaseClient}) 
      : _syncService = syncService ?? SyncService(Supabase.instance.client),
        _supabase = supabaseClient ?? Supabase.instance.client;

  Future<void> saveTheme(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.name);

    // Buffer change via SyncService
    await _syncService.updatePreference('theme', theme.name);
  }

  Future<AppTheme> getTheme() async {
    // 1. Check for global app config override (e.g., forced seasonal theme)
    try {
      final response = await _supabase
          .from('app_config')
          .select()
          .eq('key', 'seasonal_theme')
          .eq('is_active', true)
          .maybeSingle();

      if (response != null) {
        final themeName = response['value'] as String;
        return AppTheme.values.firstWhere(
          (e) => e.name == themeName,
          orElse: () => AppTheme.dark,
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch app_config: $e');
    }

    // 2. Check user profile preference if logged in
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await _supabase
            .from('profiles')
            .select('theme_preference')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null && response['theme_preference'] != null) {
          final themeName = response['theme_preference'] as String;
          return AppTheme.values.firstWhere(
            (e) => e.name == themeName,
            orElse: () => AppTheme.dark,
          );
        }
      } catch (e) {
        debugPrint('Failed to fetch user profile theme: $e');
      }
    }

    // 3. Check local storage
    final prefs = await SharedPreferences.getInstance();
    final savedThemeName = prefs.getString(_themeKey);

    if (savedThemeName != null) {
      return AppTheme.values.firstWhere(
        (e) => e.name == savedThemeName,
        orElse: () => AppTheme.dark,
      );
    }

    // 4. Fallback to auto-seasonal logic
    return _getSeasonalOrEventTheme();
  }

  AppTheme _getSeasonalOrEventTheme() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;

    // Halloween (October 25 - November 1)
    if (month == 10 && day >= 25 || month == 11 && day <= 1) {
      return AppTheme.halloween;
    }

    // Christmas (December 20 - December 31)
    if (month == 12 && day >= 20) {
      return AppTheme.christmas;
    }

    // Winter (December, January, February)
    if (month == 12 || month == 1 || month == 2) {
      return AppTheme.winter;
    }

    // Summer (June, July, August)
    if (month == 6 || month == 7 || month == 8) {
      return AppTheme.summer;
    }

    // Default to Dark
    return AppTheme.dark;
  }
}
