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
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (context) => AuthRepositoryImpl(supabase),
      child: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(
          RepositoryProvider.of<AuthRepository>(dvhwljjcsquscvpoksff),
        ),
        child: MaterialApp(
          title: 'Flutter Auth & Nav Demo',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF1C1C1E),
          ),
          // Use the AuthGate to handle routing based on auth state
          home: const AuthGate(),
        ),
      ),
    );
  }
}
