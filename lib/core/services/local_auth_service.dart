import 'dart:developer'; // Use developer log instead of print

import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

// A service class for handling biometric authentication.
class LocalAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  // Checks if the device is capable of biometric authentication.
  Future<bool> get canCheckBiometrics async {
    return await _auth.canCheckBiometrics;
  }

  // Authenticates the user using biometrics.
  // Returns true if successful, false otherwise.
  Future<bool> authenticate(String localizedReason) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Unlock your secrets',
            cancelButton: 'No thanks',
          ),
        ],
        options: const AuthenticationOptions(
          stickyAuth: true, // Keep the auth dialog open on app resume
        ),
      );
    } catch (e) {
      // Use a proper logger in a real app, but developer.log is better than print.
      log('LocalAuthService Error: $e');
      return false;
    }
  }
}
