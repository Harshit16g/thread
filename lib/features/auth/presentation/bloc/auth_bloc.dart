import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../domain/repositories/auth_repository.dart';
import 'events/auth_event.dart';
import 'states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthSignInEvent>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLoginRequested>(_onLoginRequested);
  }

  FutureOr<void> _onSignIn(AuthSignInEvent event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, signInType: event.type));
    try {
      if (event.type == AuthSignInType.google) {
        final response = await _authRepository.signInWithGoogle();
        if (response.user == null) {
          emit(state.copyWith(isLoading: false, errorMessage: 'Sign in failed.', signInType: null));
        } else {
          emit(state.copyWith(isLoading: false, signInType: null));
        }
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), signInType: null));
    }
  }

  FutureOr<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, signInType: AuthSignInType.email));
    try {
      await _authRepository.signUp(email: event.email, password: event.password);
      emit(state.copyWith(isLoading: false, signInType: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), signInType: null));
    }
  }

  FutureOr<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, signInType: AuthSignInType.email));
    try {
      final response = await _authRepository.signInWithEmail(
        email: event.email,
        password: event.password,
      );
      if (response.user == null) {
        emit(state.copyWith(isLoading: false, errorMessage: 'Login failed.', signInType: null));
      } else {
        emit(state.copyWith(isLoading: false, signInType: null));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), signInType: null));
    }
  }
}
