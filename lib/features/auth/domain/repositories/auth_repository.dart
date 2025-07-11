import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signInWithGoogle();
  Future<AuthResponse> signUp({required String email, required String password});
  Future<AuthResponse> signInWithEmail({required String email, required String password});
  Future<void> signOut();
}
