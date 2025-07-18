import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signInWithEmail(String email, String password);
  Future<void> signUpWithEmail(String email, String password);
  Future<void> signInWithOAuth(OAuthProvider provider);
  Future<void> signOut();
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
}
