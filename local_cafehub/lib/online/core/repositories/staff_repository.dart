import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:bhansa_ghar/online/core/models/staff/staff_model.dart';
import 'package:flutter/foundation.dart';

class StaffRepository {
  final ApiClient _apiClient;

  StaffRepository({required ApiClient apiClient}) : _apiClient = apiClient {
    debugPrint('StaffRepository created');
  }

  /// Get all staff members for the restaurant
  Future<StaffListResponse> getStaffList() async {
    try {
      debugPrint('StaffRepository: Fetching staff list...');
      final response = await _apiClient.getStaffList();
      debugPrint('StaffRepository: Staff list fetched successfully');
      return response;
    } catch (e) {
      debugPrint('StaffRepository: Error fetching staff list: $e');
      rethrow;
    }
  }

  /// Create a staff invitation
  Future<StaffInvitationResponse> createStaffInvitation({
    required String email,
    required String role,
  }) async {
    try {
      debugPrint(
        'StaffRepository: Creating staff invitation for $email as $role',
      );
      final request = CreateStaffInvitationRequest(email: email, role: role);
      final response = await _apiClient.createStaffInvitation(request);
      debugPrint('StaffRepository: Staff invitation created successfully');
      return response;
    } catch (e) {
      debugPrint('StaffRepository: Error creating staff invitation: $e');
      rethrow;
    }
  }

  /// Get all staff invitations
  Future<StaffInvitationListResponse> getStaffInvitations() async {
    try {
      debugPrint('StaffRepository: Fetching staff invitations...');
      final response = await _apiClient.getStaffInvitations();
      debugPrint('StaffRepository: Staff invitations fetched successfully');
      return response;
    } catch (e) {
      debugPrint('StaffRepository: Error fetching staff invitations: $e');
      rethrow;
    }
  }

  /// Remove a staff member
  Future<void> removeStaff(int staffId) async {
    try {
      debugPrint('StaffRepository: Removing staff member with ID: $staffId');
      await _apiClient.removeStaff(staffId);
      debugPrint('StaffRepository: Staff member removed successfully');
    } catch (e) {
      debugPrint('StaffRepository: Error removing staff member: $e');
      rethrow;
    }
  }

  /// Toggle staff member active status
  Future<StaffStatusToggleResponse> toggleStaffStatus({
    required int staffId,
    required bool isActive,
  }) async {
    try {
      debugPrint(
        'StaffRepository: Toggling staff status - ID: $staffId, Active: $isActive',
      );
      final request = StaffStatusToggleRequest(isActive: isActive);
      final response = await _apiClient.toggleStaffStatus(staffId, request);
      debugPrint('StaffRepository: Staff status toggled successfully');
      return response;
    } catch (e) {
      debugPrint('StaffRepository: Error toggling staff status: $e');
      rethrow;
    }
  }

  /// Delete a staff invitation
  Future<void> deleteStaffInvitation(String inviteId) async {
    try {
      debugPrint(
        'StaffRepository: Deleting staff invitation with ID: $inviteId',
      );
      await _apiClient.deleteStaffInvitation(inviteId);
      debugPrint('StaffRepository: Staff invitation deleted successfully');
    } catch (e) {
      debugPrint('StaffRepository: Error deleting staff invitation: $e');
      rethrow;
    }
  }
}
