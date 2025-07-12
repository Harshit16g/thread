import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabl/features/auth/presentation/screens/login_screen.dart';
import 'package:tabl/features/auth/presentation/screens/signup_screen.dart';
import 'package:tabl/features/auth/presentation/widgets/oauth_providers_drawer.dart';
import 'package:tabl/shared/widgets/auth_button.dart';
import 'package:tabl/shared/widgets/glass_container.dart';
import 'package:video_player/video_player.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/states/auth_state.dart';

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

  void _showProvidersDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<AuthBloc>(context),
        child: const OAuthProvidersDrawer(),
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
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthButton(
                          onPressed: () => _showProvidersDrawer(context),
                          isLoading: state.isLoading,
                          style: AuthButtonStyle.solid,
                          solidColor: Colors.black,
                          solidTextColor: Colors.white,
                          child: const Text('Continue with a Provider'),
                        ),
                        const SizedBox(height: 16.0),
                        AuthButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen())),
                          child: const Text('Sign up with Email'),
                        ),
                        const SizedBox(height: 16.0),
                        AuthButton(
                          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                          child: const Text('Log in with Email'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
