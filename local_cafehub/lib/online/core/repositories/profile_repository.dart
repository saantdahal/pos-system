import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:bhansa_ghar/online/core/models/profile/user_profile.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_update_request.dart';
import 'package:bhansa_ghar/online/core/models/profile/email_update_request.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<UserProfile> getUserProfile() async {
    return await _apiClient.getUserProfile();
  }

  Future<Map<String, dynamic>> updateUserProfile(
    ProfileUpdateRequest request, {
    String? imagePath,
  }) async {
    return await _apiClient.updateUserProfile(request, imagePath: imagePath);
  }

  Future<Map<String, dynamic>> requestEmailUpdate(
    EmailUpdateRequest request,
  ) async {
    return await _apiClient.requestEmailUpdate(request);
  }

  Future<Map<String, dynamic>> verifyEmailUpdate(
    EmailVerifyRequest request,
  ) async {
    return await _apiClient.verifyEmailUpdate(request);
  }

  Future<Map<String, dynamic>> updateMode(String mode) async {
    return await _apiClient.updateMode(mode);
  }
}
