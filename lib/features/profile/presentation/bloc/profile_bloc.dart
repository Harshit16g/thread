import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/profile_repository.dart';
import 'events/profile_event.dart';
import 'states/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final SupabaseClient _supabaseClient;

  ProfileBloc(this._profileRepository, this._supabaseClient)
      : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileAvatarUploadRequested>(_onAvatarUploadRequested);
    on<ProfileLogoutRequested>(_onLogoutRequested);
  }

  FutureOr<void> _onLoadRequested(
      ProfileLoadRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final profile = await _profileRepository.getProfile(event.userId);
      emit(state.copyWith(isLoading: false, profile: profile));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load profile: ${e.toString()}',
      ));
    }
  }

  FutureOr<void> _onUpdateRequested(
      ProfileUpdateRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      await _profileRepository.updateProfile(event.profile);
      emit(state.copyWith(
        isUpdating: false,
        profile: event.profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to update profile: ${e.toString()}',
      ));
    }
  }

  FutureOr<void> _onAvatarUploadRequested(
      ProfileAvatarUploadRequested event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(isUpdating: true, errorMessage: null));
    try {
      final avatarUrl =
          await _profileRepository.uploadAvatar(event.userId, event.filePath);
      if (state.profile != null && avatarUrl != null) {
        final updatedProfile = state.profile!.copyWith(
          avatarUrl: avatarUrl,
          updatedAt: DateTime.now(),
        );
        await _profileRepository.updateProfile(updatedProfile);
        emit(state.copyWith(
          isUpdating: false,
          profile: updatedProfile,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isUpdating: false,
        errorMessage: 'Failed to upload avatar: ${e.toString()}',
      ));
    }
  }

  FutureOr<void> _onLogoutRequested(
      ProfileLogoutRequested event, Emitter<ProfileState> emit) async {
    try {
      await _supabaseClient.auth.signOut();
      emit(const ProfileState());
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Failed to logout: ${e.toString()}',
      ));
    }
  }
}
