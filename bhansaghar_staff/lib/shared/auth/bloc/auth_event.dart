part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthGoogleLoginRequested extends AuthEvent {
  const AuthGoogleLoginRequested();
}

class AuthClaimInviteWithQR extends AuthEvent {
  final String inviteId;

  const AuthClaimInviteWithQR(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

class AuthGoogleLoginFromQR extends AuthEvent {
  final String inviteId;

  const AuthGoogleLoginFromQR(this.inviteId);

  @override
  List<Object?> get props => [inviteId];
}

class AuthGoogleLoginFromQRWithAccount extends AuthEvent {
  final String inviteId;
  final dynamic selectedAccount; // GoogleSignInAccount

  const AuthGoogleLoginFromQRWithAccount(this.inviteId, this.selectedAccount);

  @override
  List<Object?> get props => [inviteId, selectedAccount];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final UserRole role;

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, name, role];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyOtpRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class AuthRoleSelected extends AuthEvent {
  final UserRole role;

  const AuthRoleSelected(this.role);

  @override
  List<Object?> get props => [role];
}
