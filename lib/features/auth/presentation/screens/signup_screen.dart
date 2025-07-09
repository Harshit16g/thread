import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/events/auth_event.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up with Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Dispatch event to BLoC to handle sign up
                context.read<AuthBloc>().add(
                      AuthSignUpRequested(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      ),
                    );
                // Optionally show a dialog and navigate back
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sign-up request sent! Please check your email to verify.')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
