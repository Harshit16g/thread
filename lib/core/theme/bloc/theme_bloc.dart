import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/profile/presentation/bloc/profile_bloc.dart';

import '../data/theme_data.dart';
import '../data/theme_repository.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../app_theme.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeRepository _themeRepository;
  final ProfileBloc _profileBloc;
  late StreamSubscription _profileSubscription;

  ThemeBloc({
    required ThemeRepository themeRepository,
    required ProfileBloc profileBloc,
  })  : _themeRepository = themeRepository,
        _profileBloc = profileBloc,
        super(ThemeInitial()) {
    on<ThemeChanged>(_onThemeChanged);
    on<CheckSystemTheme>(_onCheckSystemTheme);
    
    // Listen to profile changes
    _profileSubscription = _profileBloc.stream.listen((state) {
      if (state.profile != null && state.profile!.themePreference != null) {
        final themeName = state.profile!.themePreference!;
        final theme = AppTheme.values.firstWhere(
          (e) => e.name == themeName,
          orElse: () => AppTheme.dark,
        );
        add(ThemeChanged(theme));
      }
    });

    // Check initial theme on startup
    add(CheckSystemTheme());
  }

  @override
  Future<void> close() {
    _profileSubscription.cancel();
    return super.close();
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    await _themeRepository.saveTheme(event.theme);
    emit(ThemeLoaded(
      themeData: AppThemeData.getTheme(event.theme),
      appTheme: event.theme,
    ));
  }

  Future<void> _onCheckSystemTheme(
    CheckSystemTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final theme = await _themeRepository.getTheme();
    emit(ThemeLoaded(
      themeData: AppThemeData.getTheme(theme),
      appTheme: theme,
    ));
  }
}
