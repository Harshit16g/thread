import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tabl/main.dart';
import 'package:tabl/shared/widgets/auth_button.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'fake_video_player_platform.dart';

void main() {
  // The main test suite
  group('Widget Tests', () {
    setUpAll(() async {
      // Ensure that the test environment is initialized
      TestWidgetsFlutterBinding.ensureInitialized();

      // Mock the video player platform
      VideoPlayerPlatform.instance = FakeVideoPlayerPlatform();

      // Load environment variables for the test environment
      await dotenv.load(fileName: ".env");

      // Set up a mock for shared_preferences before initializing Supabase
      SharedPreferences.setMockInitialValues({});

      // Initialize Supabase for testing
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
    });

    testWidgets('AuthScreen displays correctly', (WidgetTester tester) async {
      // Initialize Google Sign-In for the test
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID']!,
      );

      // Build our app and trigger a frame.
      await tester.pumpWidget(MyApp(googleSignIn: googleSignIn));

      // The app starts at AuthGate, which should show the AuthScreen.
      // Let's verify that the main auth buttons are present.
      expect(find.byType(AuthButton), findsNWidgets(3));
      expect(find.text('Continue with Social Account'), findsOneWidget);
      expect(find.text('Signup'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
