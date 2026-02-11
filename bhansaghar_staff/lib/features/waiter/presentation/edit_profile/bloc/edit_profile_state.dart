part of 'edit_profile_bloc.dart';

abstract class WaiterEditProfileState {}

class WaiterEditProfileInitial extends WaiterEditProfileState {}

class WaiterEditProfileLoading extends WaiterEditProfileState {}

class WaiterEditProfileLoaded extends WaiterEditProfileState {
  final WaiterProfileModel profile;

  WaiterEditProfileLoaded({required this.profile});
}

class WaiterEditProfileUpdating extends WaiterEditProfileState {}

class WaiterEditProfileUpdated extends WaiterEditProfileState {
  final WaiterProfileModel profile;
  final String message;

  WaiterEditProfileUpdated({required this.profile, required this.message});
}

class WaiterEmailUpdateRequested extends WaiterEditProfileState {
  final String newEmail;
  final String message;

  WaiterEmailUpdateRequested({required this.newEmail, required this.message});
}

class WaiterEmailUpdateVerifying extends WaiterEditProfileState {}

class WaiterEmailUpdateVerified extends WaiterEditProfileState {
  final WaiterProfileModel profile;
  final String message;

  WaiterEmailUpdateVerified({required this.profile, required this.message});
}

class WaiterEditProfileError extends WaiterEditProfileState {
  final String message;

  WaiterEditProfileError({required this.message});
}
