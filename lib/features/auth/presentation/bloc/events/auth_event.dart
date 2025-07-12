import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
abstract class AuthEvent {}

// Restore this enum for tracking UI state
enum AuthSignInType { google, email }

class AuthSignInEvent extends AuthEvent {
  final AuthSignInType type;
  AuthSignInEvent(this.type);
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignUpRequested({required this.email, required this.password});
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}
