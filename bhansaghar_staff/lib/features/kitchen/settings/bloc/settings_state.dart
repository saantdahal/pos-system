part of 'settings_bloc.dart';

enum AppThemeType { light, dark, industrial }

class SettingsState extends Equatable {
  final bool soundAlerts;
  final bool hapticFeedback;
  final bool visualFlash;
  final double alertVolume;
  final AppThemeType appTheme;
  final UserProfile? userProfile;
  final bool isProfileLoading;

  const SettingsState({
    this.soundAlerts = true,
    this.hapticFeedback = true,
    this.visualFlash = false,
    this.alertVolume = 0.85,
    this.appTheme = AppThemeType.dark,
    this.userProfile,
    this.isProfileLoading = false,
  });

  SettingsState copyWith({
    bool? soundAlerts,
    bool? hapticFeedback,
    bool? visualFlash,
    double? alertVolume,
    AppThemeType? appTheme,
    UserProfile? userProfile,
    bool? isProfileLoading,
  }) {
    return SettingsState(
      soundAlerts: soundAlerts ?? this.soundAlerts,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      visualFlash: visualFlash ?? this.visualFlash,
      alertVolume: alertVolume ?? this.alertVolume,
      appTheme: appTheme ?? this.appTheme,
      userProfile: userProfile ?? this.userProfile,
      isProfileLoading: isProfileLoading ?? this.isProfileLoading,
    );
  }

  @override
  List<Object?> get props => [
    soundAlerts,
    hapticFeedback,
    visualFlash,
    alertVolume,
    appTheme,
    userProfile,
    isProfileLoading,
  ];
}
