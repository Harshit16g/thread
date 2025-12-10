import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabl/features/auth/presentation/screens/login_screen.dart';
import 'package:tabl/features/auth/presentation/screens/signup_screen.dart';
import 'package:tabl/shared/widgets/auth_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/events/auth_event.dart';
import '../bloc/states/auth_state.dart';

class AuthOptionsPanel extends StatelessWidget {
  const AuthOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
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
                    onPressed: () => context.read<AuthBloc>().add(AuthSignInEvent(AuthSignInType.google)),
                    isLoading: state.isLoading && state.signInType == AuthSignInType.google,
                    style: AuthButtonStyle.solid,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.g_mobiledata_outlined),
                        SizedBox(width: 12),
                        Text('Continue with Google'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  AuthButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen())),
                    child: const Text('Sign up'),
                  ),
                  const SizedBox(height: 16.0),
                  AuthButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('Log in'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
