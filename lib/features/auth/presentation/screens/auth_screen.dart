import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/events/auth_event.dart';
import '../bloc/states/auth_state.dart';
import 'signup_screen.dart'; // Import the new screen

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: AnimatedContainer(
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            color: state.backgroundColor,
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        key: ValueKey<Color>(state.backgroundColor),
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () => context.read<AuthBloc>().add(AuthSignInEvent(AuthSignInType.google)),
                            icon: const Icon(Icons.g_mobiledata),
                            label: const Text('Continue with Google'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to the SignUpScreen
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignUpScreen()));
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: const Color(0xFF2C2C2E),
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                            ),
                            child: const Text('Sign up'),
                          ),
                          const SizedBox(height: 16.0),
                          OutlinedButton(
                            onPressed: () {
                              // TODO: Implement Log in screen
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white),
                            ),
                            child: const Text('Log in'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
