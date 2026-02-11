part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  ProfileLoaded({required this.profile});
}

class ProfileUpdating extends ProfileState {}

class ProfileUpdated extends ProfileState {
  final UserProfile profile;
  final String message;

  ProfileUpdated({required this.profile, required this.message});
}

class EmailUpdateRequesting extends ProfileState {}

class EmailUpdateRequested extends ProfileState {
  final String? pendingEmail;
  final String message;

  EmailUpdateRequested({this.pendingEmail, required this.message});
}

class EmailUpdateVerifying extends ProfileState {}

class EmailUpdateVerified extends ProfileState {
  final UserProfile profile;
  final String message;

  EmailUpdateVerified({required this.profile, required this.message});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
