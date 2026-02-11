part of 'setting_bloc.dart';

@immutable
sealed class SettingEvent {}

/// Event to load user settings and profile data
class LoadSettingsEvent extends SettingEvent {}

/// Event to refresh user settings and profile data
class RefreshSettingsEvent extends SettingEvent {}

/// Event to toggle theme between light and dark mode
class ToggleThemeSettingEvent extends SettingEvent {}

/// Event to switch app to offline mode
class SwitchToOfflineModeEvent extends SettingEvent {}

/// Event to log out the user
class LogoutEvent extends SettingEvent {}
