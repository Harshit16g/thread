import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class SupabaseOAuthSignInRequested extends AuthEvent {
  final OAuthProvider provider;
  
  const SupabaseOAuthSignInRequested(this.provider);
  
  @override
  List<Object?> get props => [provider];
}

class EmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  
  const EmailSignUpRequested(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class EmailLoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const EmailLoginRequested(this.email, this.password);
  
  @override
  List<Object?> get props => [email, password];
}

class SignOutRequested extends AuthEvent {}
