import 'dart:async';
import 'package:bloc/bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'events/auth_event.dart';
import 'states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthSignInEvent>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUpRequested);
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
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onSignUpRequested(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await _authRepository.signUp(email: event.email, password: event.password);
      emit(state.copyWith(isLoading: false, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
