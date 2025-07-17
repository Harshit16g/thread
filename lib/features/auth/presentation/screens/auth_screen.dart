import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabl/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:tabl/features/auth/presentation/bloc/events/auth_event.dart';
import 'package:tabl/features/auth/presentation/bloc/states/auth_state.dart'
    as auth_states;
import 'package:tabl/features/auth/presentation/screens/login_screen.dart';
import 'package:tabl/features/auth/presentation/screens/signup_screen.dart';
import 'package:tabl/features/home/presentation/screens/home_screen.dart';
import 'package:tabl/shared/widgets/auth_options.dart';
import 'package:tabl/shared/widgets/video_background.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _videoBackgroundKey = GlobalKey<VideoBackgroundState>();

  void _showOAuthProviders() {
    _videoBackgroundKey.currentState?.pause();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<AuthBloc>(context),
        child: const OAuthProvidersSheet(),
      ),
    ).whenComplete(() {
      if (mounted) {
        _videoBackgroundKey.currentState?.play();
      }
    });
  }

  void _navigateTo(Widget screen) {
    _videoBackgroundKey.currentState?.pause();
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AuthBloc>(),
          child: screen,
        ),
      ),
    )
        .then((_) {
      if (mounted) {
        _videoBackgroundKey.currentState?.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, auth_states.AuthState>(
        listener: (context, state) {
          if (state is auth_states.AuthAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          } else if (state is auth_states.AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoBackground(key: _videoBackgroundKey),
            Align(
              alignment: Alignment.bottomCenter,
              child: AuthOptions(
                onShowOAuth: _showOAuthProviders,
                onLogin: () => _navigateTo(const LoginScreen()),
                onSignup: () => _navigateTo(const SignUpScreen()),
              ),
            ),
            BlocBuilder<AuthBloc, auth_states.AuthState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return Stack(
                    children: [
                      // Dismissible barrier
                      GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(AuthLoadingDismissed());
                        },
                        child: Container(
                          color: Colors.black.withAlpha(77),
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      // Centered loading indicator with limited size
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
