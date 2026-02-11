import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthPinLocked extends AuthState {}

class AuthBiometricRequired extends AuthState {}

class AuthPinSetupRequired extends AuthState {}

class AuthPinVerifiedSuccess extends AuthState {}

class AuthPinSetSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  final bool isPinSet;

  const AuthFailure(this.message, {this.isPinSet = false});

  @override
  List<Object> get props => [message, isPinSet];
}
