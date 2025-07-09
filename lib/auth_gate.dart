import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/shell/presentation/screens/main_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the auth state changes from Supabase
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // If the stream has data, check if there's a session
        if (snapshot.hasData) {
          final session = snapshot.data?.session;
          // If there is no active session, show the AuthScreen
          if (session == null) {
            return const AuthScreen();
          }
          // If there is a session, show the MainScreen
          return const MainScreen();
        }
        // While waiting for the auth state, show a loading indicator
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
