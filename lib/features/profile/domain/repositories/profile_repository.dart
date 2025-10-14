import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);
  Future<void> updateProfile(UserProfile profile);
  Future<void> createProfile({
    required String userId,
    required String email,
    String? fullName,
  });
  Future<String?> uploadAvatar(String userId, String filePath);
}
