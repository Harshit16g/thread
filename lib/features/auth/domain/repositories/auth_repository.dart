import 'package:clerk_flutter/clerk_flutter.dart' as clerk;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract repository defining the contract for all authentication methods.
abstract class AuthRepository {
  /// Initiates a sign-in flow using a native Supabase OAuth provider.
  Future<void> signInWithSupabaseOAuth(OAuthProvider provider);

  /// Initiates a sign-in flow using a Clerk-managed OAuth provider.
  Future<void> signInWithClerk(clerk.OAuthProvider provider);

  /// Signs up a new user using Supabase's native email/password method.
  Future<void> signUpWithEmail(String email, String password);

  /// Signs in an existing user using Supabase's native email/password method.
  Future<void> signInWithEmail(String email, String password);

  /// Signs the user out from all active sessions (Supabase, Clerk, Google).
  Future<void> signOut();
}
