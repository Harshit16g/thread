import 'package:clerk_flutter/clerk_flutter.dart' as clerk;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  final String? _appRedirectUri = dotenv.env['APP_REDIRECT_URI'];

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<void> signInWithSupabaseOAuth(OAuthProvider provider) async {
    try {
      if (_appRedirectUri == null) throw 'APP_REDIRECT_URI is not set in .env';
      await _supabaseClient.auth.signInWithOAuth(
        provider,
        redirectTo: _appRedirectUri,
      );
    } on AuthException catch (e) {
      throw Exception('Supabase OAuth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signInWithClerk(clerk.OAuthProvider provider) async {
    try {
      return await clerk.Clerk.instance.signInWithProvider(provider);
    } catch (e) {
      throw Exception('Clerk OAuth Error: $e');
    }
  }

  @override
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      if (_appRedirectUri == null) throw 'APP_REDIRECT_URI is not set in .env';
      await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _appRedirectUri,
      );
    } on AuthException catch (e) {
      throw Exception('Sign up failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception('Sign in failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from all potential sessions
      if (await clerk.Clerk.instance.isSigned) {
        await clerk.Clerk.instance.signOut();
      }
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }
}
