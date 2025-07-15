import 'package:flutter/material.dart';
import '../events/auth_event.dart';

@immutable
class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final AuthMethod? authMethod; // To track which button shows a loader

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.authMethod,
  });

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    AuthMethod? authMethod,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      authMethod: authMethod, // Allow null to clear the method
    );
  }
}
