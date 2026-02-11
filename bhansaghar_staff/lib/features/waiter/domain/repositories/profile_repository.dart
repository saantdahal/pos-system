import 'package:bhansaghar_staff/core/api/api_client.dart';
import 'package:bhansaghar_staff/core/services/dio_service.dart';
import 'package:bhansaghar_staff/features/waiter/domain/models/profile_model.dart';

import 'dart:developer';

abstract class WaiterProfileRepository {
  Future<WaiterProfileModel> getProfile();
  Future<void> logout();
  Future<WaiterProfileModel> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? avatarPath,
  });
  Future<void> requestEmailUpdate({required String newEmail});
  Future<WaiterProfileModel> verifyEmailUpdate({required String otp});
}

class WaiterProfileRepositoryImpl extends WaiterProfileRepository {
  final ApiClient _apiClient;
  final DioService _dioService;

  WaiterProfileRepositoryImpl({
    required ApiClient apiClient,
    required DioService dioService,
  }) : _apiClient = apiClient,
       _dioService = dioService;

  @override
  Future<WaiterProfileModel> getProfile() async {
    try {
      log('📡 WaiterProfileRepository: Fetching profile...');

      // Updated endpoint to match backend staff profile endpoint
      final response = await _apiClient.get('/core/profile/staff/');

      log('✅ WaiterProfileRepository: Profile fetched successfully');
      log('📦 WaiterProfileRepository: Response data: $response');

      if (response is Map<String, dynamic>) {
        return WaiterProfileModel.fromJson(response);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      log('❌ WaiterProfileRepository: Error fetching profile: $e');
      rethrow;
    }
  }

  @override
  @override
  Future<void> logout() async {
    try {
      log('📡 WaiterProfileRepository: Logging out...');

      // Get refresh token from storage using DioService
      final refreshToken = await _dioService.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        log(
          '⚠️ WaiterProfileRepository: No refresh token found, clearing tokens anyway',
        );
        await _dioService.clearTokens();
        log(
          '✅ WaiterProfileRepository: Logged out successfully (cleared tokens)',
        );
        return;
      }

      log(
        '🔑 WaiterProfileRepository: Found refresh token, sending logout request...',
      );

      // Send logout request with refresh token in body
      await _apiClient.post('/core/logout/', data: {'refresh': refreshToken});

      // Clear tokens after successful logout
      await _dioService.clearTokens();

      log('✅ WaiterProfileRepository: Logged out successfully');
    } catch (e) {
      log('❌ WaiterProfileRepository: Error during logout: $e');
      // Even if logout fails, try to clear local tokens
      try {
        await _dioService.clearTokens();
        log(
          '✅ WaiterProfileRepository: Local tokens cleared despite logout error',
        );
      } catch (clearError) {
        log(
          '❌ WaiterProfileRepository: Failed to clear local tokens: $clearError',
        );
      }
      rethrow;
    }
  }

  @override
  Future<WaiterProfileModel> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? avatarPath,
  }) async {
    try {
      log('📡 WaiterProfileRepository: Updating profile...');

      final Map<String, dynamic> data = {
        'username': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
      };

      log('📤 FRONTEND: Request data: $data');

      final response = await _apiClient.patchWithFile(
        '/core/profile/staff/update/',
        data: data,
        avatarPath: avatarPath,
      );

      log('✅ WaiterProfileRepository: Profile updated successfully');
      log('📦 WaiterProfileRepository: Response data: $response');

      if (response is Map<String, dynamic>) {
        // If response contains 'profile' key, extract it; otherwise assume response is the profile
        final profileData = response['profile'] ?? response;
        return WaiterProfileModel.fromJson(profileData as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      log('❌ WaiterProfileRepository: Error updating profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> requestEmailUpdate({required String newEmail}) async {
    try {
      log('📡 WaiterProfileRepository: Requesting email update...');

      final response = await _apiClient.post(
        '/core/profile/staff/update-email/request/',
        data: {'new_email': newEmail},
      );

      log('✅ WaiterProfileRepository: Email update requested');
      log('📦 WaiterProfileRepository: Response data: $response');
    } catch (e) {
      log('❌ WaiterProfileRepository: Error requesting email update: $e');
      rethrow;
    }
  }

  @override
  Future<WaiterProfileModel> verifyEmailUpdate({required String otp}) async {
    try {
      log('📡 WaiterProfileRepository: Verifying email update...');

      final response = await _apiClient.post(
        '/core/profile/staff/update-email/verify/',
        data: {'otp': otp},
      );

      log('✅ WaiterProfileRepository: Email verified successfully');
      log('📦 WaiterProfileRepository: Response data: $response');

      if (response is Map<String, dynamic>) {
        // If response contains 'profile' key, extract it; otherwise assume response is the profile
        final profileData = response['profile'] ?? response;
        return WaiterProfileModel.fromJson(profileData as Map<String, dynamic>);
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      log('❌ WaiterProfileRepository: Error verifying email: $e');
      rethrow;
    }
  }
}
