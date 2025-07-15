import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:tabl/features/auth/domain/repositories/auth_repository.dart';
import 'package:tabl/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:tabl/features/auth/presentation/bloc/states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<SupabaseOAuthSignInRequested>(_onSupabaseOAuthSignIn);
    on<ClerkSignInRequested>(_onClerkSignIn);
    on<EmailSignUpRequested>(_onEmailSignUp);
    on<EmailLoginRequested>(_onEmailLogin);
  }

  FutureOr<void> _onSupabaseOAuthSignIn(
      SupabaseOAuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, authMethod: AuthMethod.supabase));
    try {
      await _authRepository.signInWithSupabaseOAuth(event.provider);
      emit(state.copyWith(isLoading: false, authMethod: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), authMethod: null));
    }
  }

  FutureOr<void> _onClerkSignIn(
      ClerkSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, authMethod: AuthMethod.clerk));
    try {
      await _authRepository.signInWithClerk(event.provider);
      emit(state.copyWith(isLoading: false, authMethod: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), authMethod: null));
    }
  }

  FutureOr<void> _onEmailSignUp(
      EmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, authMethod: AuthMethod.email));
    try {
      await _authRepository.signUpWithEmail(event.email, event.password);
      emit(state.copyWith(isLoading: false, authMethod: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), authMethod: null));
    }
  }

  FutureOr<void> _onEmailLogin(
      EmailLoginRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true, authMethod: AuthMethod.email));
    try {
      await _authRepository.signInWithEmail(event.email, event.password);
      emit(state.copyWith(isLoading: false, authMethod: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString(), authMethod: null));
    }
  }
}
