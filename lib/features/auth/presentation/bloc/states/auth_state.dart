import 'package:flutter/material.dart';
import 'package:tabl/features/auth/presentation/bloc/events/auth_event.dart';

@immutable
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final AuthSignInType? signInType;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.signInType,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthSignInType? signInType,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      signInType: signInType ?? this.signInType,
    );
  }
}
