part of 'edit_profile_bloc.dart';

abstract class WaiterEditProfileEvent {}

class LoadWaiterProfileEvent extends WaiterEditProfileEvent {}

class UpdateWaiterProfileEvent extends WaiterEditProfileEvent {
  final String firstName;
  final String? phone;
  final String? address;
  final String? avatarPath;

  UpdateWaiterProfileEvent({
    required this.firstName,
    this.phone,
    this.address,
    this.avatarPath,
  });
}

class RequestEmailUpdateEvent extends WaiterEditProfileEvent {
  final String newEmail;

  RequestEmailUpdateEvent({required this.newEmail});
}

class VerifyEmailUpdateEvent extends WaiterEditProfileEvent {
  final String otp;

  VerifyEmailUpdateEvent({required this.otp});
}
