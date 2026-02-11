import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthPinSet extends AuthEvent {
  final String pin;

  const AuthPinSet(this.pin);

  @override
  List<Object> get props => [pin];
}

class AuthPinVerified extends AuthEvent {
  final String pin;

  const AuthPinVerified(this.pin);

  @override
  List<Object> get props => [pin];
}

class AuthPinDisabled extends AuthEvent {}

class AuthBiometricRequested extends AuthEvent {}

class AuthBiometricEnabled extends AuthEvent {
  final bool enabled;

  const AuthBiometricEnabled(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class AuthBiometricDisabled extends AuthEvent {}
