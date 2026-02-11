import 'dart:developer';
import 'package:bhansaghar_staff/features/waiter/domain/repositories/profile_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class WaiterProfileBloc extends Bloc<WaiterProfileEvent, WaiterProfileState> {
  final WaiterProfileRepository _profileRepository;

  WaiterProfileBloc({required WaiterProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const WaiterProfileInitial()) {
    on<FetchWaiterProfileEvent>(_onFetchProfile);
    on<WaiterLogoutEvent>(_onLogout);
    on<UpdateWaiterProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onFetchProfile(
    FetchWaiterProfileEvent event,
    Emitter<WaiterProfileState> emit,
  ) async {
    emit(const WaiterProfileLoading());
    try {
      log('🔄 WaiterProfileBloc: Fetching profile...');

      final profile = await _profileRepository.getProfile();

      log('✅ WaiterProfileBloc: Profile loaded successfully');
      log('👤 WaiterProfileBloc: ID: ${profile.id}');
      log(
        '👤 WaiterProfileBloc: Name: ${profile.firstName}, Role: ${profile.role}',
      );
      log('👤 WaiterProfileBloc: Location: ${profile.location}');
      log('👤 WaiterProfileBloc: Image URL: ${profile.profileImageUrl}');
      log('👤 WaiterProfileBloc: Verified: ${profile.isVerified}');
      log('👤 WaiterProfileBloc: Orders: ${profile.ordersServedToday}');

      emit(
        WaiterProfileLoaded(
          name: profile.firstName ?? 'User',
          role: profile.role,
          location: profile.location,
          profileImageUrl: profile.profileImageUrl,
          ordersServedToday: profile.ordersServedToday,
          isVerified: profile.isVerified,
        ),
      );
    } catch (e, stackTrace) {
      log('❌ WaiterProfileBloc: Error fetching profile: $e');
      log('❌ WaiterProfileBloc: Stack trace: $stackTrace');
      emit(WaiterProfileError('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onLogout(
    WaiterLogoutEvent event,
    Emitter<WaiterProfileState> emit,
  ) async {
    emit(const WaiterProfileLoading());
    try {
      log('🔄 WaiterProfileBloc: Logging out...');

      await _profileRepository.logout();

      log('✅ WaiterProfileBloc: Logged out successfully');
      emit(const WaiterLogoutSuccess());
    } catch (e) {
      log('❌ WaiterProfileBloc: Error during logout: $e');
      emit(WaiterProfileError('Logout failed: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateWaiterProfileEvent event,
    Emitter<WaiterProfileState> emit,
  ) async {
    emit(const WaiterProfileLoading());
    try {
      log('🔄 WaiterProfileBloc: Updating profile...');

      final updatedProfile = await _profileRepository.updateProfile(
        name: event.name,
        phone: event.phone,
        address: event.address,
        avatarPath: event.avatarPath,
      );

      log('✅ WaiterProfileBloc: Profile updated successfully');

      emit(
        WaiterProfileLoaded(
          name: updatedProfile.firstName ?? 'User',
          role: updatedProfile.role,
          location: updatedProfile.location,
          profileImageUrl: updatedProfile.profileImageUrl,
          ordersServedToday: updatedProfile.ordersServedToday,
          isVerified: updatedProfile.isVerified,
        ),
      );
    } catch (e) {
      log('❌ WaiterProfileBloc: Error updating profile: $e');
      emit(WaiterProfileError('Profile update failed: ${e.toString()}'));
    }
  }
}
