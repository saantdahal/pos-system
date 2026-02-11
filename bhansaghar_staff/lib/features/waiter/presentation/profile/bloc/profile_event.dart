part of 'profile_bloc.dart';

abstract class WaiterProfileEvent extends Equatable {
  const WaiterProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchWaiterProfileEvent extends WaiterProfileEvent {
  const FetchWaiterProfileEvent();
}

class WaiterLogoutEvent extends WaiterProfileEvent {
  const WaiterLogoutEvent();
}

class UpdateWaiterProfileEvent extends WaiterProfileEvent {
  final String name;
  final String? phone;
  final String? address;
  final String? avatarPath;

  const UpdateWaiterProfileEvent({
    required this.name,
    this.phone,
    this.address,
    this.avatarPath,
  });

  @override
  List<Object?> get props => [name, phone, address, avatarPath];
}
