part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class ToggleSoundAlerts extends SettingsEvent {
  final bool value;
  const ToggleSoundAlerts(this.value);

  @override
  List<Object?> get props => [value];
}

class ToggleHapticFeedback extends SettingsEvent {
  final bool value;
  const ToggleHapticFeedback(this.value);

  @override
  List<Object?> get props => [value];
}

class ToggleVisualFlash extends SettingsEvent {
  final bool value;
  const ToggleVisualFlash(this.value);

  @override
  List<Object?> get props => [value];
}

class ChangeAlertVolume extends SettingsEvent {
  final double volume;
  const ChangeAlertVolume(this.volume);

  @override
  List<Object?> get props => [volume];
}

class ChangeAppTheme extends SettingsEvent {
  final AppThemeType theme;
  const ChangeAppTheme(this.theme);

  @override
  List<Object?> get props => [theme];
}

class LoadProfileEvent extends SettingsEvent {}
