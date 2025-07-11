import 'package:flutter/material.dart';
import '../events/auth_event.dart'; // Import events to get AuthSignInType

@immutable
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  // Add this field to track which sign-in process is active
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
