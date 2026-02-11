import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/core/repositories/staff_repository.dart';
import 'package:bhansa_ghar/online/core/services/user_friendly_response_service.dart';
import 'staff_event.dart';
import 'staff_state.dart';

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository _staffRepository;

  StaffBloc({required StaffRepository staffRepository})
    : _staffRepository = staffRepository,
      super(StaffInitial()) {
    on<FetchStaffList>(_onFetchStaffList);
    on<FetchStaffInvitations>(_onFetchStaffInvitations);
    on<CreateStaffInvitation>(_onCreateStaffInvitation);
    on<DeleteStaffInvitation>(_onDeleteStaffInvitation);
    on<RemoveStaff>(_onRemoveStaff);
    on<ToggleStaffStatus>(_onToggleStaffStatus);
    on<RefreshStaffList>(_onRefreshStaffList);
  }

  Future<void> _onFetchStaffList(
    FetchStaffList event,
    Emitter<StaffState> emit,
  ) async {
    // Only emit loading if we don't have data yet
    if (state is! StaffLoaded) {
      emit(StaffLoading());
    }

    try {
      debugPrint('StaffBloc: Fetching staff list...');
      final response = await _staffRepository.getStaffList();
      debugPrint(
        'StaffBloc: Staff list loaded - ${response.staff.length} members',
      );

      if (state is StaffLoaded) {
        emit(
          (state as StaffLoaded).copyWith(
            staffMembers: response.staff,
            staffCount: response.count,
          ),
        );
      } else {
        emit(
          StaffLoaded(staffMembers: response.staff, staffCount: response.count),
        );
      }
    } catch (e) {
      debugPrint('StaffBloc: Error fetching staff list: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(StaffError(message: errorMessage));
    }
  }

  Future<void> _onFetchStaffInvitations(
    FetchStaffInvitations event,
    Emitter<StaffState> emit,
  ) async {
    // Only emit loading if we don't have data yet
    if (state is! StaffLoaded) {
      emit(StaffLoading());
    }

    try {
      debugPrint('StaffBloc: Fetching staff invitations...');
      final response = await _staffRepository.getStaffInvitations();
      debugPrint(
        'StaffBloc: Staff invitations loaded - ${response.invitations.length} invitations',
      );

      if (state is StaffLoaded) {
        emit(
          (state as StaffLoaded).copyWith(
            invitations: response.invitations,
            invitationsCount: response.count,
          ),
        );
      } else {
        emit(
          StaffLoaded(
            invitations: response.invitations,
            invitationsCount: response.count,
          ),
        );
      }
    } catch (e) {
      debugPrint('StaffBloc: Error fetching staff invitations: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(StaffError(message: errorMessage));
    }
  }

  Future<void> _onCreateStaffInvitation(
    CreateStaffInvitation event,
    Emitter<StaffState> emit,
  ) async {
    try {
      debugPrint('StaffBloc: Creating staff invitation for ${event.email}...');
      final response = await _staffRepository.createStaffInvitation(
        email: event.email,
        role: event.role,
      );
      debugPrint('StaffBloc: Staff invitation created successfully');
      emit(StaffInvitationCreated(invitation: response.invite));

      // Fetch updated invitations list
      await _onFetchStaffInvitations(FetchStaffInvitations(), emit);
    } catch (e) {
      debugPrint('StaffBloc: Error creating staff invitation: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(StaffError(message: errorMessage));
    }
  }

  Future<void> _onDeleteStaffInvitation(
    DeleteStaffInvitation event,
    Emitter<StaffState> emit,
  ) async {
    try {
      debugPrint(
        'StaffBloc: Deleting staff invitation with ID: ${event.inviteId}',
      );
      await _staffRepository.deleteStaffInvitation(event.inviteId);
      debugPrint('StaffBloc: Staff invitation deleted successfully');
      emit(StaffInvitationDeleted(inviteId: event.inviteId));

      // Fetch updated invitations list
      await _onFetchStaffInvitations(FetchStaffInvitations(), emit);
    } catch (e) {
      debugPrint('StaffBloc: Error deleting staff invitation: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(StaffError(message: errorMessage));
    }
  }

  Future<void> _onRemoveStaff(
    RemoveStaff event,
    Emitter<StaffState> emit,
  ) async {
    try {
      debugPrint('StaffBloc: Removing staff member with ID: ${event.staffId}');
      await _staffRepository.removeStaff(event.staffId);
      debugPrint('StaffBloc: Staff member removed successfully');
      emit(StaffRemoved(staffId: event.staffId));

      // Fetch updated list
      await _onFetchStaffList(FetchStaffList(), emit);
    } catch (e) {
      debugPrint('StaffBloc: Error removing staff member: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(StaffError(message: errorMessage));
    }
  }

  Future<void> _onToggleStaffStatus(
    ToggleStaffStatus event,
    Emitter<StaffState> emit,
  ) async {
    try {
      debugPrint(
        'StaffBloc: Toggling staff status - ID: ${event.staffId}, Active: ${event.isActive}',
      );
      final response = await _staffRepository.toggleStaffStatus(
        staffId: event.staffId,
        isActive: event.isActive,
      );
      debugPrint('StaffBloc: Staff status toggled successfully');
      emit(StaffStatusToggled(staffMember: response.staff));

      // Fetch updated list
      await _onFetchStaffList(FetchStaffList(), emit);
    } catch (e) {
      debugPrint('StaffBloc: Error toggling staff status: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(StaffError(message: errorMessage));
    }
  }

  Future<void> _onRefreshStaffList(
    RefreshStaffList event,
    Emitter<StaffState> emit,
  ) async {
    debugPrint('StaffBloc: Refreshing staff list...');
    await _onFetchStaffList(FetchStaffList(), emit);
  }
}
