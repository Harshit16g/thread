import 'package:clerk_flutter/clerk_flutter.dart' as clerk;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabl/shared/widgets/auth_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/events/auth_event.dart';

/// A modal bottom sheet that displays a list of Clerk-managed OAuth providers.
class ClerkProvidersDrawer extends StatelessWidget {
  const ClerkProvidersDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Define your list of Clerk providers here for easy management
    final providers = [
      {'name': 'Apple', 'provider': clerk.OAuthProvider.apple, 'icon': Icons.apple},
      {'name': 'Microsoft', 'provider': clerk.OAuthProvider.microsoft, 'icon': Icons.mic_external_on_outlined},
      {'name': 'LinkedIn', 'provider': clerk.OAuthProvider.linkedin, 'icon': Icons.link},
      // You can add 'Hugging Face' here if you find a suitable icon
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
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
          Text(
            'More sign-in options',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...providers.map((p) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: AuthButton(
                onPressed: () {
                  context.read<AuthBloc>().add(ClerkSignInRequested(p['provider'] as clerk.OAuthProvider));
                  Navigator.of(context).pop(); // Close the drawer
                },
                style: AuthButtonStyle.solid,
                solidColor: Colors.grey.shade800,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(p['icon'] as IconData),
                    const SizedBox(width: 12),
                    Text(p['name'] as String),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
