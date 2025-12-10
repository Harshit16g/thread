import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _supabaseClient;

  ProfileRepositoryImpl(this._supabaseClient);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      // Return null if profile doesn't exist
      if (e is PostgrestException && e.code == 'PGRST116') {
        return null;
      }
      throw Exception('Failed to fetch profile: $e');
    }
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    try {
      final model = UserProfileModel(
        id: profile.id,
        email: profile.email,
        fullName: profile.fullName,
        avatarUrl: profile.avatarUrl,
        bio: profile.bio,
        phoneNumber: profile.phoneNumber,
        createdAt: profile.createdAt,
        updatedAt: DateTime.now(),
      );

      await _supabaseClient.from('profiles').update(model.toJson()).eq('id', profile.id);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }



  @override
  Future<String?> uploadAvatar(String userId, String filePath) async {
    try {
      final file = File(filePath);
      final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      await _supabaseClient.storage
          .from('avatars')
          .upload(fileName, file);

      final publicUrl = _supabaseClient.storage
          .from('avatars')
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
