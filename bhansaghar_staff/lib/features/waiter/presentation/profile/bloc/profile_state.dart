part of 'profile_bloc.dart';

abstract class WaiterProfileState extends Equatable {
  const WaiterProfileState();

  @override
  List<Object?> get props => [];
}

class WaiterProfileInitial extends WaiterProfileState {
  const WaiterProfileInitial();
}

class WaiterProfileLoading extends WaiterProfileState {
  const WaiterProfileLoading();
}

class WaiterProfileLoaded extends WaiterProfileState {
  final String name;
  final String role;
  final String location;
  final String? profileImageUrl;
  final int ordersServedToday;
  final bool isVerified;

  const WaiterProfileLoaded({
    required this.name,
    required this.role,
    required this.location,
    this.profileImageUrl,
    required this.ordersServedToday,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [
    name,
    role,
    location,
    profileImageUrl,
    ordersServedToday,
    isVerified,
  ];
}

class WaiterProfileError extends WaiterProfileState {
  final String message;

  const WaiterProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class WaiterLogoutSuccess extends WaiterProfileState {
  const WaiterLogoutSuccess();
}
