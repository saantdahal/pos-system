import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_request.dart';

abstract class OnlineAuthEvent extends Equatable {
  const OnlineAuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends OnlineAuthEvent {}

class GoogleLoginRequested extends OnlineAuthEvent {}

class OtpVerificationRequested extends OnlineAuthEvent {
  final String email;
  final String code;

  const OtpVerificationRequested({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}

class ResendOtpRequested extends OnlineAuthEvent {
  final String email;

  const ResendOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class ProfileCompletionRequested extends OnlineAuthEvent {
  final ProfileRequest request;
  const ProfileCompletionRequested(this.request);

  @override
  List<Object?> get props => [request];
}

class ModeSelectionRequested extends OnlineAuthEvent {
  final String mode;
  const ModeSelectionRequested(this.mode);

  @override
  List<Object?> get props => [mode];
}

class RestaurantSetupCompleted extends OnlineAuthEvent {
  final dynamic response; // RestaurantResponse
  const RestaurantSetupCompleted(this.response);

  @override
  List<Object?> get props => [response];
}

class LogoutRequested extends OnlineAuthEvent {}
