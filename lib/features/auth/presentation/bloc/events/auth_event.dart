import 'package:clerk_flutter/clerk_flutter.dart' as clerk;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@immutable
abstract class AuthEvent {}

/// Dispatched when a Supabase-native OAuth provider is selected.
class SupabaseOAuthSignInRequested extends AuthEvent {
  final OAuthProvider provider;
  SupabaseOAuthSignInRequested(this.provider);
}

/// Dispatched when a Clerk-managed provider is selected.
class ClerkSignInRequested extends AuthEvent {
  final clerk.OAuthProvider provider;
  ClerkSignInRequested(this.provider);
}

/// Dispatched when the user tries to sign up with email and password.
class EmailSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  EmailSignUpRequested(this.email, this.password);
}

/// Dispatched when the user tries to log in with email and password.
class EmailLoginRequested extends AuthEvent {
  final String email;
  final String password;
  EmailLoginRequested(this.email, this.password);
}
