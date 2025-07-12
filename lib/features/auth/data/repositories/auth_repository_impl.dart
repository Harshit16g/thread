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
      if (_googleWebClientId == null) throw 'GOOGLE_WEB_CLIENT_ID is not set.';
      final googleSignIn = GoogleSignIn(serverClientId: _googleWebClientId);
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      if (idToken == null) throw 'Google Sign-In failed: No idToken.';
      return await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponse> signUp({required String email, required String password}) async {
    try {
      if (_appRedirectUri == null) throw 'APP_REDIRECT_URI is not set.';
      return await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _appRedirectUri,
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponse> signInWithEmail({required String email, required String password}) async {
    try {
      return await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await _supabaseClient.auth.signOut();
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
