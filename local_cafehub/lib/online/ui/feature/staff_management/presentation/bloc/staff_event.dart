import 'package:equatable/equatable.dart';

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class FetchStaffList extends StaffEvent {
  const FetchStaffList();
}

class FetchStaffInvitations extends StaffEvent {
  const FetchStaffInvitations();
}

class CreateStaffInvitation extends StaffEvent {
  final String email;
  final String role;

  const CreateStaffInvitation({required this.email, required this.role});

  @override
  List<Object?> get props => [email, role];
}

class RemoveStaff extends StaffEvent {
  final int staffId;

  const RemoveStaff({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}

class ToggleStaffStatus extends StaffEvent {
  final int staffId;
  final bool isActive;

  const ToggleStaffStatus({required this.staffId, required this.isActive});

  @override
  List<Object?> get props => [staffId, isActive];
}

class RefreshStaffList extends StaffEvent {
  const RefreshStaffList();
}

class DeleteStaffInvitation extends StaffEvent {
  final String inviteId;

  const DeleteStaffInvitation({required this.inviteId});

  @override
  List<Object?> get props => [inviteId];
}
