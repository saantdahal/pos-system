import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:bhansa_ghar/core/bloc/mode/mode_bloc.dart';
import 'package:bhansa_ghar/offline/core/bloc/theme/theme_bloc.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/core/repositories/profile_repository.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final ThemeBloc _themeBloc;
  final ModeBloc _modeBloc;

  SettingBloc({
    required AuthRepository authRepository,
    required ProfileRepository profileRepository,
    required ThemeBloc themeBloc,
    required ModeBloc modeBloc,
  }) : _authRepository = authRepository,
       _profileRepository = profileRepository,
       _themeBloc = themeBloc,
       _modeBloc = modeBloc,
       super(SettingInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<RefreshSettingsEvent>(_onRefreshSettings);
    on<ToggleThemeSettingEvent>(_onToggleTheme);
    on<SwitchToOfflineModeEvent>(_onSwitchToOfflineMode);
    on<LogoutEvent>(_onLogout);
  }

  /// Load user settings and profile data
  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<SettingState> emit,
  ) async {
    final wasAlreadyLoaded = state is SettingLoaded;
    if (!wasAlreadyLoaded) {
      emit(SettingLoading());
    }
    try {
      // Fetch fresh profile data from backend
      final profile = await _profileRepository.getUserProfile();

      debugPrint(
        '🔍 SETTINGS - PROFILE DATA FROM BACKEND: ${profile.toJson()}',
      );
      debugPrint('📋 Settings Profile Details:');
      debugPrint('   - Username: ${profile.username}');
      debugPrint('   - Email: ${profile.email}');
      debugPrint('   - Avatar: ${profile.avatar}');
      debugPrint('   - Restaurant: ${profile.restaurant?.name}');
      debugPrint('   - Role: ${profile.role}');

      // Get current theme state
      final isDarkMode = _themeBloc.state.isDarkMode;

      // Emit the state first
      emit(
        SettingLoaded(
          userEmail: profile.email,
          restaurantName: profile.restaurant?.name,
          phone: profile.phone,
          address: profile.address,
          username: profile.username,
          userRole: profile.role,
          avatar: profile.avatar,
          isDarkMode: isDarkMode,
        ),
      );

      // Then try to save to local storage (non-blocking)
      try {
        await _authRepository.saveProfileDataFromMap(profile.toJson());
        debugPrint('✅ Profile data saved to local storage');
      } catch (saveError) {
        debugPrint(
          '⚠️ Failed to save to local storage: ${saveError.toString()}',
        );
      }
    } catch (e) {
      debugPrint('❌ Failed to load settings from backend: ${e.toString()}');

      // Fallback to local storage if API fails
      try {
        final email = await _authRepository.getUserEmail();
        final profileData = await _authRepository.getProfileData();
        final isDarkMode = _themeBloc.state.isDarkMode;

        debugPrint('⚠️ Using cached profile data from local storage');

        emit(
          SettingLoaded(
            userEmail: email,
            restaurantName: profileData?['restaurantName'],
            phone: profileData?['phone'],
            address: profileData?['address'],
            username: profileData?['username'],
            userRole: profileData?['role'],
            avatar: profileData?['avatar'],
            isDarkMode: isDarkMode,
          ),
        );
      } catch (fallbackError) {
        if (!wasAlreadyLoaded) {
          emit(
            SettingError(
              'Failed to load settings: ${fallbackError.toString()}',
            ),
          );
        }
      }
    }
  }

  /// Refresh user settings and profile data (used when profile is updated)
  Future<void> _onRefreshSettings(
    RefreshSettingsEvent event,
    Emitter<SettingState> emit,
  ) async {
    try {
      // Fetch fresh profile data from backend
      final profile = await _profileRepository.getUserProfile();

      debugPrint('🔄 SETTINGS - REFRESHED PROFILE DATA: ${profile.toJson()}');

      // Get current theme state
      final isDarkMode = _themeBloc.state.isDarkMode;

      // Emit the state first
      emit(
        SettingLoaded(
          userEmail: profile.email,
          restaurantName: profile.restaurant?.name,
          phone: profile.phone,
          address: profile.address,
          username: profile.username,
          userRole: profile.role,
          avatar: profile.avatar,
          isDarkMode: isDarkMode,
        ),
      );

      // Then try to save to local storage (non-blocking)
      try {
        await _authRepository.saveProfileDataFromMap(profile.toJson());
        debugPrint('✅ Profile data refreshed and saved to local storage');
      } catch (saveError) {
        debugPrint(
          '⚠️ Failed to save to local storage: ${saveError.toString()}',
        );
      }
    } catch (e) {
      // Don't emit error on refresh, just keep current state
      debugPrint('❌ Failed to refresh settings: ${e.toString()}');
    }
  }

  /// Toggle theme between light and dark mode
  void _onToggleTheme(
    ToggleThemeSettingEvent event,
    Emitter<SettingState> emit,
  ) {
    // Dispatch toggle theme event to ThemeBloc
    _themeBloc.add(ToggleThemeEvent() as ThemeEvent);

    // Update current state with new theme
    if (state is SettingLoaded) {
      final currentState = state as SettingLoaded;
      emit(currentState.copyWith(isDarkMode: !currentState.isDarkMode));
    }
  }

  /// Switch app to offline mode
  Future<void> _onSwitchToOfflineMode(
    SwitchToOfflineModeEvent event,
    Emitter<SettingState> emit,
  ) async {
    try {
      // Update mode in backend
      await _profileRepository.updateMode('offline');
      // Dispatch mode change event to ModeBloc
      _modeBloc.add(const ModeChanged(AppMode.offline));
    } catch (e) {
      debugPrint('Failed to update mode in backend: $e');
      // Still switch to offline mode locally even if backend update fails
      _modeBloc.add(const ModeChanged(AppMode.offline));
    }
  }

  /// Log out the user
  Future<void> _onLogout(LogoutEvent event, Emitter<SettingState> emit) async {
    try {
      await _authRepository.signOut();
      emit(LogoutSuccess());
    } catch (e) {
      emit(SettingError('Failed to logout: ${e.toString()}'));
    }
  }
}
