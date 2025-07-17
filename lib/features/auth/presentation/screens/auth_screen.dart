import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tabl/features/auth/presentation/screens/login_screen.dart';
import 'package:tabl/features/auth/presentation/screens/signup_screen.dart';
import 'package:tabl/shared/widgets/auth_button.dart';
import 'package:tabl/shared/widgets/glass_container.dart';
import 'package:video_player/video_player.dart';
import 'package:tabl/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tabl/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:tabl/features/auth/presentation/bloc/states/auth_state.dart' as auth_states;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/animations/splashscreen.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showOAuthProviders(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<AuthBloc>(context),
        child: _OAuthProvidersSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: _controller.value.isInitialized
                ? SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  )
                : const SizedBox(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassContainer(
              borderRadius: 0,
              customBorderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24, 24, 24,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // OAuth button
                    AuthButton(
                      onPressed: () => _showOAuthProviders(context),
                      style: AuthButtonStyle.solid,
                      solidColor: Colors.black,
                      solidTextColor: Colors.white,
                      child: const Text('OAuth'),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Signup button
                    AuthButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AuthBloc>(),
                            child: const SignUpScreen(),
                          ),
                        ),
                      ),
                      child: const Text('Signup'),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Login button
                    AuthButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AuthBloc>(),
                            child: const LoginScreen(),
                          ),
                        ),
                      ),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// OAuth Providers Bottom Sheet
class _OAuthProvidersSheet extends StatelessWidget {
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
          24, 24, 24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
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
            
            // Google
            _ProviderButton(
              icon: Icons.g_mobiledata_outlined,
              label: 'Continue with Google',
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(
                  const SupabaseOAuthSignInRequested(OAuthProvider.google),
                );
              },
            ),
            const SizedBox(height: 12),
            
            // GitHub
            _ProviderButton(
              icon: Icons.code,
              label: 'Continue with GitHub',
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(
                  const SupabaseOAuthSignInRequested(OAuthProvider.github),
                );
              },
            ),
            const SizedBox(height: 12),
            
            // LinkedIn
            _ProviderButton(
              icon: Icons.work_outline,
              label: 'Continue with LinkedIn',
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(
                  const SupabaseOAuthSignInRequested(OAuthProvider.linkedin),
                );
              },
            ),
            const SizedBox(height: 12),
            
            // Azure
            _ProviderButton(
              icon: Icons.business,
              label: 'Continue with Azure',
              onPressed: () {
                Navigator.pop(context);
                context.read<AuthBloc>().add(
                  const SupabaseOAuthSignInRequested(OAuthProvider.azure),
                );
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
      color: Colors.white.withOpacity(0.1),
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
