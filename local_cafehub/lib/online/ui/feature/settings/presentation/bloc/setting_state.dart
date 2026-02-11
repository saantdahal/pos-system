part of 'setting_bloc.dart';

@immutable
sealed class SettingState {}

/// Initial state before any data is loaded
final class SettingInitial extends SettingState {}

/// Loading state while fetching user data
final class SettingLoading extends SettingState {}

/// Loaded state with user profile data
final class SettingLoaded extends SettingState {
  final String? userEmail;
  final String? restaurantName;
  final String? phone;
  final String? address;
  final String? username;
  final String? userRole;
  final String? avatar;
  final bool isDarkMode;

  SettingLoaded({
    this.userEmail,
    this.restaurantName,
    this.phone,
    this.address,
    this.username,
    this.userRole,
    this.avatar,
    required this.isDarkMode,
  });

  SettingLoaded copyWith({
    String? userEmail,
    String? restaurantName,
    String? phone,
    String? address,
    String? username,
    String? userRole,
    String? avatar,
    bool? isDarkMode,
  }) {
    return SettingLoaded(
      userEmail: userEmail ?? this.userEmail,
      restaurantName: restaurantName ?? this.restaurantName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      username: username ?? this.username,
      userRole: userRole ?? this.userRole,
      avatar: avatar ?? this.avatar,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}

/// Error state with error message
final class SettingError extends SettingState {
  final String message;

  SettingError(this.message);
}

/// Success state after logout
final class LogoutSuccess extends SettingState {}
