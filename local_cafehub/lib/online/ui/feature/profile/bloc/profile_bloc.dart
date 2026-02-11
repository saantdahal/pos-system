import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:bhansa_ghar/online/core/repositories/profile_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/core/models/profile/user_profile.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_update_request.dart';
import 'package:bhansa_ghar/online/core/models/profile/email_update_request.dart';
import 'package:bhansa_ghar/online/core/services/user_friendly_response_service.dart';
import 'package:bhansa_ghar/online/ui/feature/settings/presentation/bloc/setting_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final AuthRepository _authRepository;
  final SettingBloc _settingBloc;

  ProfileBloc({
    required ProfileRepository profileRepository,
    required AuthRepository authRepository,
    required SettingBloc settingBloc,
  }) : _profileRepository = profileRepository,
       _authRepository = authRepository,
       _settingBloc = settingBloc,
       super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<RequestEmailUpdateEvent>(_onRequestEmailUpdate);
    on<VerifyEmailUpdateEvent>(_onVerifyEmailUpdate);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final profile = await _profileRepository.getUserProfile();
      debugPrint('🔍 PROFILE DATA FROM BACKEND (Load): ${profile.toJson()}');
      debugPrint('📋 Profile Details:');
      debugPrint('   - ID: ${profile.id}');
      debugPrint('   - Username: ${profile.username}');
      debugPrint('   - Email: ${profile.email}');
      debugPrint('   - Phone: ${profile.phone}');
      debugPrint('   - Address: ${profile.address}');
      debugPrint('   - Latitude: ${profile.latitude}');
      debugPrint('   - Longitude: ${profile.longitude}');
      debugPrint('   - Avatar: ${profile.avatar}');
      debugPrint('   - Role: ${profile.role}');
      debugPrint('   - Is Google Verified: ${profile.isGoogleVerified}');
      debugPrint('   - Is Email Verified: ${profile.isEmailVerified}');
      debugPrint('   - Profile Completed: ${profile.profileCompleted}');
      debugPrint('   - Restaurant: ${profile.restaurant?.toJson()}');

      // Update local storage with the loaded profile data
      await _authRepository.saveProfileDataFromMap(profile.toJson());

      emit(ProfileLoaded(profile: profile));
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(ProfileError(message: errorMessage));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());
    try {
      final response = await _profileRepository.updateUserProfile(
        event.request,
        imagePath: event.imagePath,
      );
      // Reload profile after update
      final updatedProfile = await _profileRepository.getUserProfile();
      debugPrint(
        '🔄 PROFILE DATA FROM BACKEND (Update): ${updatedProfile.toJson()}',
      );
      debugPrint('📋 Updated Profile Details:');
      debugPrint('   - ID: ${updatedProfile.id}');
      debugPrint('   - Username: ${updatedProfile.username}');
      debugPrint('   - Email: ${updatedProfile.email}');
      debugPrint('   - Phone: ${updatedProfile.phone}');
      debugPrint('   - Address: ${updatedProfile.address}');
      debugPrint('   - Latitude: ${updatedProfile.latitude}');
      debugPrint('   - Longitude: ${updatedProfile.longitude}');
      debugPrint('   - Avatar: ${updatedProfile.avatar}');
      debugPrint('   - Role: ${updatedProfile.role}');
      debugPrint('   - Is Google Verified: ${updatedProfile.isGoogleVerified}');
      debugPrint('   - Is Email Verified: ${updatedProfile.isEmailVerified}');
      debugPrint('   - Profile Completed: ${updatedProfile.profileCompleted}');
      debugPrint('   - Restaurant: ${updatedProfile.restaurant?.toJson()}');

      // Update local storage with the new profile data
      await _authRepository.saveProfileDataFromMap(updatedProfile.toJson());

      emit(
        ProfileUpdated(
          profile: updatedProfile,
          message: response['message'] ?? 'Profile updated successfully',
        ),
      );

      // Refresh settings to update avatar display
      _settingBloc.add(RefreshSettingsEvent());
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(ProfileError(message: errorMessage));
    }
  }

  Future<void> _onRequestEmailUpdate(
    RequestEmailUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(EmailUpdateRequesting());
    try {
      final response = await _profileRepository.requestEmailUpdate(
        event.request,
      );
      emit(
        EmailUpdateRequested(
          pendingEmail: response['pending_email'],
          message:
              response['message'] ?? 'Verification code sent to your new email',
        ),
      );
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(ProfileError(message: errorMessage));
    }
  }

  Future<void> _onVerifyEmailUpdate(
    VerifyEmailUpdateEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(EmailUpdateVerifying());
    try {
      final response = await _profileRepository.verifyEmailUpdate(
        event.request,
      );
      // Reload profile after email update
      final updatedProfile = await _profileRepository.getUserProfile();
      debugPrint(
        '📧 PROFILE DATA FROM BACKEND (Email Update): ${updatedProfile.toJson()}',
      );
      debugPrint('📋 Email Updated Profile Details:');
      debugPrint('   - ID: ${updatedProfile.id}');
      debugPrint('   - Username: ${updatedProfile.username}');
      debugPrint('   - Email: ${updatedProfile.email}');
      debugPrint('   - Phone: ${updatedProfile.phone}');
      debugPrint('   - Address: ${updatedProfile.address}');
      debugPrint('   - Latitude: ${updatedProfile.latitude}');
      debugPrint('   - Longitude: ${updatedProfile.longitude}');
      debugPrint('   - Avatar: ${updatedProfile.avatar}');
      debugPrint('   - Role: ${updatedProfile.role}');
      debugPrint('   - Is Google Verified: ${updatedProfile.isGoogleVerified}');
      debugPrint('   - Is Email Verified: ${updatedProfile.isEmailVerified}');
      debugPrint('   - Profile Completed: ${updatedProfile.profileCompleted}');
      debugPrint('   - Restaurant: ${updatedProfile.restaurant?.toJson()}');
      emit(
        EmailUpdateVerified(
          profile: updatedProfile,
          message: response['message'] ?? 'Email updated successfully',
        ),
      );
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(ProfileError(message: errorMessage));
    }
  }
}
