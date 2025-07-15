import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Clerk with your publishable key
  await Clerk.initialize(
    publishableKey: dotenv.env['CLERK_PUBLISHABLE_KEY']!,
  );

  // Initialize Supabase. The authCallback is the bridge.
  // It tells Supabase to get its token from Clerk's session.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: FlutterAuthClient(
      authCallback: () async {
        // This token MUST be the one generated from your Clerk JWT Template for Supabase
        return await Clerk.instance.session?.getToken(template: 'supabase') ?? '';
      },
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClerkProvider(
      child: RepositoryProvider<AuthRepository>(
        create: (context) => AuthRepositoryImpl(Supabase.instance.client),
        child: BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            RepositoryProvider.of<AuthRepository>(context),
          ),
          child: MaterialApp(
            title: 'TabL',
            debugShowCheckedModeBanner: false,
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: const Color(0xFF0F2027),
            ),
            home: const AuthGate(),
          ),
        ),
      ),
    );
  }
}
