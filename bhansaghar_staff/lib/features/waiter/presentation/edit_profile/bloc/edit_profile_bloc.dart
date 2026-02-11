import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/profile_model.dart';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/profile_repository.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

class WaiterEditProfileBloc
    extends Bloc<WaiterEditProfileEvent, WaiterEditProfileState> {
  final WaiterProfileRepository _profileRepository;

  WaiterEditProfileBloc({required WaiterProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(WaiterEditProfileInitial()) {
    on<LoadWaiterProfileEvent>(_onLoadProfile);
    on<UpdateWaiterProfileEvent>(_onUpdateProfile);
    on<RequestEmailUpdateEvent>(_onRequestEmailUpdate);
    on<VerifyEmailUpdateEvent>(_onVerifyEmailUpdate);
  }

  Future<void> _onLoadProfile(
    LoadWaiterProfileEvent event,
    Emitter<WaiterEditProfileState> emit,
  ) async {
    emit(WaiterEditProfileLoading());
    try {
      final profile = await _profileRepository.getProfile();
      debugPrint('👤 WaiterEditProfileBloc: Profile loaded');
      debugPrint('   - ID: ${profile.id}');
      debugPrint('   - Name: ${profile.firstName}');
      debugPrint('   - Email: ${profile.email}');
      debugPrint('   - Location: ${profile.location}');

      emit(WaiterEditProfileLoaded(profile: profile));
    } catch (e) {
      debugPrint('❌ WaiterEditProfileBloc: Error loading profile: $e');
      emit(
        WaiterEditProfileError(
          message: 'Failed to load profile: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onUpdateProfile(
    UpdateWaiterProfileEvent event,
    Emitter<WaiterEditProfileState> emit,
  ) async {
    emit(WaiterEditProfileUpdating());
    try {
      final updatedProfile = await _profileRepository.updateProfile(
        name: event.firstName,
        phone: event.phone,
        address: event.address,
        avatarPath: event.avatarPath,
      );

      debugPrint('✅ WaiterEditProfileBloc: Profile updated successfully');
      debugPrint('   - Name: ${updatedProfile.firstName}');
      debugPrint('   - Phone: ${updatedProfile.phone}');
      debugPrint('   - Address: ${updatedProfile.address}');
      debugPrint('   - Avatar: ${updatedProfile.profileImageUrl}');

      emit(
        WaiterEditProfileUpdated(
          profile: updatedProfile,
          message: 'Profile updated successfully',
        ),
      );
    } catch (e) {
      debugPrint('❌ WaiterEditProfileBloc: Error updating profile: $e');
      emit(
        WaiterEditProfileError(
          message: 'Failed to update profile: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onRequestEmailUpdate(
    RequestEmailUpdateEvent event,
    Emitter<WaiterEditProfileState> emit,
  ) async {
    try {
      debugPrint('📧 WaiterEditProfileBloc: Requesting email update');
      debugPrint('   - New Email: ${event.newEmail}');

      await _profileRepository.requestEmailUpdate(newEmail: event.newEmail);

      debugPrint('✅ WaiterEditProfileBloc: Email update requested');
      debugPrint('   - OTP sent to: ${event.newEmail}');

      emit(
        WaiterEmailUpdateRequested(
          newEmail: event.newEmail,
          message: 'Verification code sent to ${event.newEmail}',
        ),
      );
    } catch (e) {
      debugPrint('❌ WaiterEditProfileBloc: Error requesting email update: $e');
      emit(
        WaiterEditProfileError(
          message: 'Failed to request email update: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onVerifyEmailUpdate(
    VerifyEmailUpdateEvent event,
    Emitter<WaiterEditProfileState> emit,
  ) async {
    emit(WaiterEmailUpdateVerifying());
    try {
      debugPrint('🔐 WaiterEditProfileBloc: Verifying email update');
      debugPrint('   - OTP: ${event.otp}');

      final updatedProfile = await _profileRepository.verifyEmailUpdate(
        otp: event.otp,
      );

      debugPrint('✅ WaiterEditProfileBloc: Email updated successfully');
      debugPrint('   - New Email: ${updatedProfile.email}');

      emit(
        WaiterEmailUpdateVerified(
          profile: updatedProfile,
          message: 'Email updated successfully',
        ),
      );
    } catch (e) {
      debugPrint('❌ WaiterEditProfileBloc: Error verifying email: $e');
      emit(
        WaiterEditProfileError(
          message: 'Failed to verify email: ${e.toString()}',
        ),
      );
    }
  }
}
