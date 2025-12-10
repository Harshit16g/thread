import 'package:flutter/material.dart';
import '../../../domain/entities/user_profile.dart';

@immutable
class ProfileState {
  final bool isLoading;
  final UserProfile? profile;
  final String? errorMessage;
  final bool isUpdating;

  const ProfileState({
    this.isLoading = false,
    this.profile,
    this.errorMessage,
    this.isUpdating = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    UserProfile? profile,
    String? errorMessage,
    bool? isUpdating,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      profile: profile ?? this.profile,
      errorMessage: errorMessage,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}
