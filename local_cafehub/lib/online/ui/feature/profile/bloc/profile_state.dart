part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UserProfile profile;

  ProfileLoaded({required this.profile});
}

final class ProfileUpdating extends ProfileState {}

final class ProfileUpdated extends ProfileState {
  final UserProfile profile;
  final String message;

  ProfileUpdated({required this.profile, required this.message});
}

final class EmailUpdateRequesting extends ProfileState {}

final class EmailUpdateRequested extends ProfileState {
  final String? pendingEmail;
  final String message;

  EmailUpdateRequested({this.pendingEmail, required this.message});
}

final class EmailUpdateVerifying extends ProfileState {}

final class EmailUpdateVerified extends ProfileState {
  final UserProfile profile;
  final String message;

  EmailUpdateVerified({required this.profile, required this.message});
}

final class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}
