import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tabl/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tabl/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:tabl/shared/widgets/auth_button.dart';
import 'package:tabl/shared/widgets/glass_container.dart';

class AuthOptions extends StatelessWidget {
  final VoidCallback onShowOAuth;
  final VoidCallback onLogin;
  final VoidCallback onSignup;

  const AuthOptions({
    super.key,
    required this.onShowOAuth,
    required this.onLogin,
    required this.onSignup,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthButton(
              onPressed: onShowOAuth,
              style: AuthButtonStyle.solid,
              solidColor: Colors.black,
              solidTextColor: Colors.white,
              child: const Text('Continue with Social Account'),
            ),
            const SizedBox(height: 16.0),
            AuthButton(
              onPressed: onSignup,
              child: const Text('Signup'),
            ),
            const SizedBox(height: 16.0),
            AuthButton(
              onPressed: onLogin,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class OAuthProvidersSheet extends StatelessWidget {
  const OAuthProvidersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 0,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Choose OAuth Provider',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _ProviderButton(
              icon: Icons.g_mobiledata_outlined,
              label: 'Continue with Google',
              onPressed: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(const SupabaseOAuthSignInRequested(OAuthProvider.google));
              },
            ),
            const SizedBox(height: 12),
            _ProviderButton(
              icon: Icons.code,
              label: 'Continue with GitHub',
              onPressed: () {
                Navigator.pop(context);
                context
                    .read<AuthBloc>()
                    .add(const SupabaseOAuthSignInRequested(OAuthProvider.github));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ProviderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(26),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
