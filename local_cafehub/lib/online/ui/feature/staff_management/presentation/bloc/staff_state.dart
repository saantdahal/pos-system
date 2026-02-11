import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/staff/staff_model.dart';

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {
  const StaffInitial();
}

class StaffLoading extends StaffState {
  const StaffLoading();
}

class StaffLoaded extends StaffState {
  final List<StaffMember> staffMembers;
  final int staffCount;
  final List<StaffInvitation> invitations;
  final int invitationsCount;

  const StaffLoaded({
    this.staffMembers = const [],
    this.staffCount = 0,
    this.invitations = const [],
    this.invitationsCount = 0,
  });

  StaffLoaded copyWith({
    List<StaffMember>? staffMembers,
    int? staffCount,
    List<StaffInvitation>? invitations,
    int? invitationsCount,
  }) {
    return StaffLoaded(
      staffMembers: staffMembers ?? this.staffMembers,
      staffCount: staffCount ?? this.staffCount,
      invitations: invitations ?? this.invitations,
      invitationsCount: invitationsCount ?? this.invitationsCount,
    );
  }

  @override
  List<Object?> get props => [
    staffMembers,
    staffCount,
    invitations,
    invitationsCount,
  ];
}

class StaffInvitationCreated extends StaffState {
  final StaffInvitation invitation;

  const StaffInvitationCreated({required this.invitation});

  @override
  List<Object?> get props => [invitation];
}

class StaffRemoved extends StaffState {
  final int staffId;

  const StaffRemoved({required this.staffId});

  @override
  List<Object?> get props => [staffId];
}

class StaffInvitationDeleted extends StaffState {
  final String inviteId;

  const StaffInvitationDeleted({required this.inviteId});

  @override
  List<Object?> get props => [inviteId];
}

class StaffStatusToggled extends StaffState {
  final StaffMember staffMember;

  const StaffStatusToggled({required this.staffMember});

  @override
  List<Object?> get props => [staffMember];
}

class StaffError extends StaffState {
  final String message;

  const StaffError({required this.message});

  @override
  List<Object?> get props => [message];
}
