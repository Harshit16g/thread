import 'package:flutter/material.dart';

@immutable
class AuthState {
  final Color backgroundColor;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    required this.backgroundColor,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    Color? backgroundColor,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
