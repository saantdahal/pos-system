part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent {}

class LoadProfileEvent extends ProfileEvent {}

class UpdateProfileEvent extends ProfileEvent {
  final ProfileUpdateRequest request;
  final String? imagePath;

  UpdateProfileEvent({required this.request, this.imagePath});
}

class RequestEmailUpdateEvent extends ProfileEvent {
  final EmailUpdateRequest request;

  RequestEmailUpdateEvent({required this.request});
}

class VerifyEmailUpdateEvent extends ProfileEvent {
  final EmailVerifyRequest request;

  VerifyEmailUpdateEvent({required this.request});
}
