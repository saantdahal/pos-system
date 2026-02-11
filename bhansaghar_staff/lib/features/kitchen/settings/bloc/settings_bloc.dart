import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bhansaghar_staff/core/repositories/profile_repository.dart';
import 'package:bhansaghar_staff/core/models/profile/user_profile.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ProfileRepository _profileRepository;

  SettingsBloc({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const SettingsState()) {
    on<ToggleSoundAlerts>((event, emit) {
      emit(state.copyWith(soundAlerts: event.value));
    });

    on<ToggleHapticFeedback>((event, emit) {
      emit(state.copyWith(hapticFeedback: event.value));
    });

    on<ToggleVisualFlash>((event, emit) {
      emit(state.copyWith(visualFlash: event.value));
    });

    on<ChangeAlertVolume>((event, emit) {
      emit(state.copyWith(alertVolume: event.volume));
    });

    on<ChangeAppTheme>((event, emit) {
      emit(state.copyWith(appTheme: event.theme));
    });

    on<LoadProfileEvent>(_onLoadProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isProfileLoading: true));
    try {
      final profile = await _profileRepository.getUserProfile();
      emit(state.copyWith(userProfile: profile, isProfileLoading: false));
    } catch (e) {
      emit(state.copyWith(isProfileLoading: false));
      // Handle error - maybe emit an error state
    }
  }
}
