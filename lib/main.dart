import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Google Sign-In
  final googleSignIn = GoogleSignIn(
    serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID']!,
  );

  runApp(MyApp(googleSignIn: googleSignIn));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.googleSignIn});

  final GoogleSignIn googleSignIn;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(
        Supabase.instance.client,
        googleSignIn,
      ),
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
    );
  }
}
