import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import 'events/auth_event.dart';
import 'states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final List<Color> _backgroundColors = [
    const Color(0xFFF76C5E),
    const Color(0xFF4A90E2),
    const Color(0xFF50E3C2),
    const Color(0xFFFFD700),
    const Color(0xFFE94E77),
  ];
  int _currentIndex = 0;
  Timer? _colorChangeTimer;

  AuthBloc(this._authRepository) : super(AuthState(backgroundColor: const Color(0xFFF76C5E))) {
    on<AuthChangeColorEvent>(_onChangeColor);
    on<AuthSignInEvent>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUpRequested);

    _startColorChangeTimer();
  }

  void _startColorChangeTimer() {
    _colorChangeTimer?.cancel(); // Cancel any existing timer
    _colorChangeTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      add(AuthChangeColorEvent());
    });
  }

  FutureOr<void> _onChangeColor(AuthChangeColorEvent event, Emitter<AuthState> emit) {
    _currentIndex = (_currentIndex + 1) % _backgroundColors.length;
    emit(state.copyWith(backgroundColor: _backgroundColors[_currentIndex]));
  }

  FutureOr<void> _onSignIn(AuthSignInEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      if (event.type == AuthSignInType.google) {
        final response = await _authRepository.signInWithGoogle();
        if (response.user == null) {
          emit(state.copyWith(isLoading: false, errorMessage: 'Sign in failed.'));
        }
      }
      // The actual success state is handled by the auth stream listener
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authRepository.signUp(email: event.email, password: event.password);
      // Let user know they need to check their email
      // We don't sign them in until they have verified
      emit(state.copyWith(isLoading: false, errorMessage: null));
      // Optionally navigate back or show a success dialog
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _colorChangeTimer?.cancel();
    return super.close();
  }
}
