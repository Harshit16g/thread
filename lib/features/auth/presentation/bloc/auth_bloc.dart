import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:tabl/features/auth/domain/repositories/auth_repository.dart';
import 'package:tabl/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:tabl/features/auth/presentation/bloc/states/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<sb.AuthState>? _authStateSubscription;

  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SupabaseOAuthSignInRequested>(_onSupabaseOAuthSignIn);
    on<EmailSignUpRequested>(_onEmailSignUp);
    on<EmailLoginRequested>(_onEmailLogin);
    on<SignOutRequested>(_onSignOut);
    on<AuthLoadingDismissed>(_onAuthLoadingDismissed);

    _authStateSubscription =
        _authRepository.authStateChanges.listen((authState) {
      if (authState.session != null) {
        add(CheckAuthStatus());
      }
    });
  }

  FutureOr<void> _onCheckAuthStatus(
      CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = _authRepository.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  FutureOr<void> _onSupabaseOAuthSignIn(
      SupabaseOAuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(authMethod: AuthMethod.oauth));
    try {
      await _authRepository.signInWithOAuth(event.provider);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _onEmailSignUp(
      EmailSignUpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(authMethod: AuthMethod.email));
    try {
      await _authRepository.signUpWithEmail(event.email, event.password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _onEmailLogin(
      EmailLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(authMethod: AuthMethod.email));
    try {
      await _authRepository.signInWithEmail(event.email, event.password);
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _onSignOut(
      SignOutRequested event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  FutureOr<void> _onAuthLoadingDismissed(
      AuthLoadingDismissed event, Emitter<AuthState> emit) {
    emit(state.copyWith(isLoading: false));
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}
