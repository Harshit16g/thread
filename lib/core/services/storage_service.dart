import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// A service class for handling secure, encrypted storage.
// This uses flutter_secure_storage to store data in the platform's
// keychain (iOS) or keystore (Android).
class StorageService {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> write({required String key, required String value}) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String?> read({required String key}) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> delete({required String key}) async {
    await _secureStorage.delete(key: key);
  }
}
