import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

@immutable
abstract class AuthEvent {}

class AuthChangeColorEvent extends AuthEvent {}

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
