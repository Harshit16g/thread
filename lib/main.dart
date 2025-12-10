import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart'; // Import AuthGate
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'core/theme/data/theme_repository.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/sync/sync_service.dart';

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SyncService>(
          create: (context) => SyncService(supabase)..checkAndSync(),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepositoryImpl(supabase),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => ProfileRepositoryImpl(supabase),
        ),
        RepositoryProvider<ThemeRepository>(
          create: (context) => ThemeRepository(
            syncService: RepositoryProvider.of<SyncService>(context),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              RepositoryProvider.of<ProfileRepository>(context),
              supabase,
              RepositoryProvider.of<SyncService>(context),
            ),
          ),
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(
              themeRepository: RepositoryProvider.of<ThemeRepository>(context),
              profileBloc: BlocProvider.of<ProfileBloc>(context),
            ),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            ThemeData theme = ThemeData.dark(); // Default fallback
            if (state is ThemeLoaded) {
              theme = state.themeData;
            }
            
            return MaterialApp(
              title: 'TabL',
              debugShowCheckedModeBanner: false,
              theme: theme,
              // Set AuthGate as the home. It will correctly show the AuthScreen
              // with its video background.
              home: const AuthGate(),
            );
          },
        ),
      ),
    );
  }
}
