import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/auth/auth_response.dart';

abstract class OnlineAuthState extends Equatable {
  const OnlineAuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends OnlineAuthState {}

class AuthLoading extends OnlineAuthState {}

class Unauthenticated extends OnlineAuthState {}

class NeedsOtpVerification extends OnlineAuthState {
  final String email;
  final String? verificationCode; // For development
  const NeedsOtpVerification(this.email, {this.verificationCode});

  @override
  List<Object?> get props => [email, verificationCode];
}

class OtpResent extends OnlineAuthState {}

class NeedsProfileCompletion extends OnlineAuthState {
  final AuthResponse authResponse;
  final String email;
  const NeedsProfileCompletion(this.authResponse, this.email);

  @override
  List<Object?> get props => [authResponse, email];
}

class NeedsModeSelection extends OnlineAuthState {
  final AuthResponse authResponse;
  const NeedsModeSelection(this.authResponse);

  @override
  List<Object?> get props => [authResponse];
}

class NeedsRestaurantSetup extends OnlineAuthState {
  final AuthResponse authResponse;
  final Map<String, dynamic>? profileData;
  const NeedsRestaurantSetup(this.authResponse, [this.profileData]);

  @override
  List<Object?> get props => [authResponse, profileData];
}

class Authenticated extends OnlineAuthState {
  final AuthResponse authResponse;
  const Authenticated(this.authResponse);

  @override
  List<Object?> get props => [authResponse];
}

class AuthFailure extends OnlineAuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}
