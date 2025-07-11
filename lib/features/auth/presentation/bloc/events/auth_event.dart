import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent {}

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

// Event for logging in with email and password
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}
