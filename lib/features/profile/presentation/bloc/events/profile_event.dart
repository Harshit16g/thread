import 'package:flutter/material.dart';
import '../../../domain/entities/user_profile.dart';

@immutable
abstract class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {
  final String userId;
  ProfileLoadRequested(this.userId);
}

class ProfileUpdateRequested extends ProfileEvent {
  final UserProfile profile;
  ProfileUpdateRequested(this.profile);
}

class ProfileAvatarUploadRequested extends ProfileEvent {
  final String userId;
  final String filePath;
  ProfileAvatarUploadRequested(this.userId, this.filePath);
}

class ProfileLogoutRequested extends ProfileEvent {}
