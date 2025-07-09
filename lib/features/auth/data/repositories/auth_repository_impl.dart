import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  final String? _googleWebClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
  final String? _appRedirectUri = dotenv.env['APP_REDIRECT_URI'];

  AuthRepositoryImpl(this._supabaseClient);

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      if (_googleWebClientId == null) {
        throw 'GOOGLE_WEB_CLIENT_ID is not set in the .env file.';
      }

      final googleSignIn = GoogleSignIn(serverClientId: _googleWebClientId);
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Google Sign-In failed: No idToken received.';
      }

      return await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } on AuthException catch (e) {
      throw Exception('Supabase sign-in failed: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password}) async {
    try {
      if (_appRedirectUri == null) {
        throw 'APP_REDIRECT_URI is not set in the .env file.';
      }
      // Tell Supabase to send a verification email and redirect to our app
      // using the deep link.
      return await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _appRedirectUri,
      );
    } on AuthException catch (e) {
      throw Exception('Failed to sign up: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Also sign out from Google to allow account switching
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await _supabaseClient.auth.signOut();
    } on AuthException catch (e) {
      throw Exception('Failed to sign out: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
