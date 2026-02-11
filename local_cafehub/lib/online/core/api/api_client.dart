import 'dart:io';
import 'package:bhansa_ghar/online/core/models/auth/auth_response.dart';
import 'package:bhansa_ghar/online/core/models/auth/google_auth_request.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_request.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_response.dart';
import 'package:bhansa_ghar/online/core/models/staff/staff_model.dart';
import 'package:dio/dio.dart';
import 'package:bhansa_ghar/online/core/api/api_const.dart';
import 'package:bhansa_ghar/online/core/models/auth/google_auth_response.dart';
import 'package:bhansa_ghar/online/core/models/category/category.dart';
import 'package:bhansa_ghar/online/core/models/category/category_request.dart';
import 'package:bhansa_ghar/online/core/models/profile/user_profile.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_update_request.dart';
import 'package:bhansa_ghar/online/core/models/profile/email_update_request.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_request.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_response.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_type.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant.dart';
import 'package:bhansa_ghar/online/core/models/user/user_info.dart';
import 'package:flutter/material.dart';

class ApiClient {
  final Dio _dio;
  final String baseUrl;
  late final Dio _dioNoAuth;

  ApiClient(this._dio, {required this.baseUrl}) {
    _dioNoAuth = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<GoogleAuthResponse> googleAuth(GoogleAuthRequest request) async {
    debugPrint('ApiClient: googleAuth called with baseUrl: $baseUrl');
    final response = await _dioNoAuth.post(
      ApiConst.googleAuth,
      data: request.toJson(),
    );
    return GoogleAuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        ApiConst.verifyOtp,
        data: {'email': email, 'code': code},
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic> && errorData.containsKey('error')) {
        throw errorData['error'];
      }
      throw e.message ?? 'Verification failed';
    }
  }

  Future<void> resendOtp({required String email}) async {
    await _dio.post(ApiConst.resendOtp, data: {'email': email});
  }

  Future<ProfileResponse> completeProfile(ProfileRequest request) async {
    final response = await _dio.post(
      ApiConst.completeProfile,
      data: request.toJson(),
    );
    return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserProfile> getUserProfile() async {
    final response = await _dio.get(ApiConst.getProfile);
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> updateUserProfile(
    ProfileUpdateRequest request, {
    String? imagePath,
  }) async {
    debugPrint('🔄 API: updateUserProfile called with imagePath: $imagePath');
    if (imagePath != null && imagePath.isNotEmpty) {
      debugPrint('📸 API: Uploading profile with image');
      // Create FormData with text fields, excluding avatar since we're sending the file
      final Map<String, dynamic> formDataMap = {};
      if (request.username != null) formDataMap['username'] = request.username;
      if (request.phone != null) formDataMap['phone'] = request.phone;
      if (request.address != null) formDataMap['address'] = request.address;
      // Note: avatar field is excluded when uploading file

      debugPrint('📝 API: Form data fields: $formDataMap');

      // Validate that the image file exists
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist: $imagePath');
      }
      debugPrint(
        '📸 API: Image file exists at: $imagePath, size: ${await imageFile.length()} bytes',
      );

      final formData = FormData.fromMap(formDataMap);
      formData.files.add(
        MapEntry('avatar', await MultipartFile.fromFile(imagePath)),
      );

      debugPrint('📤 API: Sending PATCH request to ${ApiConst.updateProfile}');
      try {
        final response = await _dio.patch(
          ApiConst.updateProfile,
          data: formData,
        );
        debugPrint('✅ API: Profile update successful');
        return response.data as Map<String, dynamic>;
      } catch (e) {
        debugPrint('❌ API: Profile update failed: $e');
        rethrow;
      }
    } else {
      debugPrint('📝 API: Updating profile without image');
      // Use JSON when no image
      final response = await _dio.patch(
        ApiConst.updateProfile,
        data: request.toJson(),
      );
      return response.data as Map<String, dynamic>;
    }
  }

  Future<Map<String, dynamic>> requestEmailUpdate(
    EmailUpdateRequest request,
  ) async {
    final response = await _dio.post(
      ApiConst.requestEmailUpdate,
      data: request.toJson(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyEmailUpdate(
    EmailVerifyRequest request,
  ) async {
    final response = await _dio.post(
      ApiConst.verifyEmailUpdate,
      data: request.toJson(),
    );
    return response.data as Map<String, dynamic>;
  }

  Future<AuthResponse> selectMode({
    required String email,
    required String mode,
  }) async {
    final response = await _dio.post(
      ApiConst.selectMode,
      data: {'email': email, 'selected_mode': mode},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConst.refreshToken,
      data: {'refresh': refreshToken},
    );
    return AuthResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserInfo> testUserInfo() async {
    final response = await _dio.get(ApiConst.testUser);
    return UserInfo.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> checkAdminStatus() async {
    await _dio.get(ApiConst.adminStatus);
  }

  Future<RestaurantResponse> createRestaurant(RestaurantRequest request) async {
    try {
      debugPrint(
        'ApiClient: createRestaurant called with data: ${request.toJson()}',
      );
      final response = await _dio.post(
        ApiConst.createRestaurant,
        data: request.toJson(),
      );
      debugPrint('ApiClient: createRestaurant response: ${response.data}');
      return RestaurantResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('ApiClient: createRestaurant failed with error: ${e.message}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw errorData['detail'] ??
            errorData['message'] ??
            e.message ??
            'Failed to create restaurant';
      }
      throw e.message ?? 'Failed to create restaurant';
    }
  }

  Future<List<RestaurantType>> getRestaurantTypes() async {
    final response = await _dioNoAuth.get(ApiConst.getRestaurantTypes);
    final data = response.data as List<dynamic>;
    return data
        .map((json) => RestaurantType.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Restaurant> getRestaurant() async {
    try {
      debugPrint('ApiClient: getRestaurant called');
      debugPrint('ApiClient: Endpoint: ${ApiConst.getRestaurant}');
      final response = await _dio.get(ApiConst.getRestaurant);
      debugPrint('ApiClient: Raw response data: ${response.data}');
      debugPrint('ApiClient: Response data type: ${response.data.runtimeType}');

      if (response.data == null) {
        throw Exception('Restaurant response is null');
      }

      // Parse the response as a single restaurant object
      final restaurant = Restaurant.fromJson(
        response.data as Map<String, dynamic>,
      );

      debugPrint(
        'ApiClient: Retrieved restaurant: ${restaurant.name ?? "Unknown"}',
      );
      debugPrint('ApiClient: Restaurant ID: ${restaurant.id}');
      debugPrint('ApiClient: Restaurant Type: ${restaurant.type?.displayName}');

      return restaurant;
    } on DioException catch (e) {
      debugPrint('ApiClient: getRestaurant failed with error: ${e.message}');
      debugPrint('ApiClient: Error response data: ${e.response?.data}');
      debugPrint('ApiClient: Status code: ${e.response?.statusCode}');
      throw e.response?.data['error'] ??
          e.message ??
          'Failed to fetch restaurant';
    } catch (e) {
      debugPrint('ApiClient: getRestaurant failed with parsing error: $e');
      debugPrint('ApiClient: Error details: ${e.toString()}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateRestaurant(
    RestaurantUpdateRequest request,
  ) async {
    try {
      debugPrint(
        'ApiClient: updateRestaurant called with data: ${request.toJson()}',
      );
      final response = await _dio.patch(
        ApiConst.updateRestaurant,
        data: request.toJson(),
      );
      debugPrint('ApiClient: Restaurant updated successfully');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiClient: updateRestaurant failed with error: ${e.message}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw errorData['detail'] ??
            errorData['message'] ??
            e.message ??
            'Failed to update restaurant';
      }
      throw e.message ?? 'Failed to update restaurant';
    }
  }

  Future<Map<String, dynamic>> updateMode(String mode) async {
    try {
      debugPrint('ApiClient: updateMode called with mode: $mode');
      final response = await _dio.post(
        ApiConst.updateMode,
        data: {'mode': mode},
      );
      debugPrint('ApiClient: updateMode response: ${response.data}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiClient: updateMode failed with error: ${e.message}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      throw e.response?.data['error'] ?? e.message ?? 'Failed to update mode';
    }
  }

  Future<Map<String, dynamic>> getAdminStatus() async {
    final response = await _dio.get(ApiConst.adminStatus);
    return response.data as Map<String, dynamic>;
  }

  /// Category API Methods

  Future<List<Category>> listCategories() async {
    try {
      debugPrint('ApiClient: listCategories called');
      final response = await _dio.get(ApiConst.listCategories);
      final data = response.data as List<dynamic>;
      final categories = data
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();
      debugPrint('ApiClient: Retrieved ${categories.length} categories');
      return categories;
    } on DioException catch (e) {
      debugPrint('ApiClient: listCategories failed with error: ${e.message}');
      throw e.message ?? 'Failed to fetch categories';
    }
  }

  Future<Category> createCategory(CategoryRequest request) async {
    try {
      debugPrint(
        'ApiClient: createCategory called with data: ${request.toJson()}',
      );
      final response = await _dio.post(
        ApiConst.createCategory,
        data: request.toJson(),
      );
      debugPrint('ApiClient: createCategory response: ${response.data}');
      return Category.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('ApiClient: createCategory failed with error: ${e.message}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw errorData['detail'] ??
            errorData['message'] ??
            e.message ??
            'Failed to create category';
      }
      throw e.message ?? 'Failed to create category';
    }
  }

  Future<Category> getCategoryDetail(int id) async {
    try {
      debugPrint('ApiClient: getCategoryDetail called with id: $id');
      final response = await _dio.get(
        ApiConst.getCategoryDetail.replaceAll('{id}', '$id'),
      );
      debugPrint('ApiClient: getCategoryDetail response: ${response.data}');
      return Category.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint(
        'ApiClient: getCategoryDetail failed with error: ${e.message}',
      );
      throw e.message ?? 'Failed to fetch category';
    }
  }

  Future<Category> updateCategory(int id, CategoryRequest request) async {
    try {
      debugPrint(
        'ApiClient: updateCategory called with id: $id, data: ${request.toJson()}',
      );
      final response = await _dio.put(
        ApiConst.updateCategory.replaceAll('{id}', '$id'),
        data: request.toJson(),
      );
      debugPrint('ApiClient: updateCategory response: ${response.data}');
      return Category.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('ApiClient: updateCategory failed with error: ${e.message}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw errorData['detail'] ??
            errorData['message'] ??
            e.message ??
            'Failed to update category';
      }
      throw e.message ?? 'Failed to update category';
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      debugPrint('ApiClient: deleteCategory called with id: $id');
      await _dio.delete(ApiConst.deleteCategory.replaceAll('{id}', '$id'));
      debugPrint('ApiClient: Category deleted successfully');
    } on DioException catch (e) {
      debugPrint('ApiClient: deleteCategory failed with error: ${e.message}');
      throw e.message ?? 'Failed to delete category';
    }
  }

  /// Table API Methods

  Future<List<dynamic>> listTables() async {
    try {
      debugPrint('ApiClient: listTables called');
      final response = await _dio.get(ApiConst.listTables);
      debugPrint('ApiClient: Retrieved response data: ${response.data}');

      // Handle both paginated and non-paginated responses
      if (response.data is List) {
        debugPrint(
          'ApiClient: Retrieved ${response.data.length} tables (direct list)',
        );
        return response.data as List<dynamic>;
      } else if (response.data is Map && response.data.containsKey('results')) {
        debugPrint(
          'ApiClient: Retrieved ${response.data['results'].length} tables (paginated)',
        );
        return response.data['results'] as List<dynamic>;
      } else {
        debugPrint(
          'ApiClient: Unexpected response format: ${response.data.runtimeType}',
        );
        throw 'Unexpected response format from server';
      }
    } on DioException catch (e) {
      debugPrint('ApiClient: listTables failed with error: ${e.message}');
      throw e.message ?? 'Failed to list tables';
    }
  }

  Future<dynamic> createTable(Map<String, dynamic> request) async {
    try {
      debugPrint('ApiClient: createTable called with data: $request');
      final response = await _dio.post(ApiConst.createTable, data: request);
      debugPrint('ApiClient: Table created successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient: createTable failed with error: ${e.message}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw errorData['detail'] ??
            errorData['message'] ??
            e.message ??
            'Failed to create table';
      }
      throw e.message ?? 'Failed to create table';
    }
  }

  Future<List<dynamic>> createBulkTables(int count) async {
    try {
      debugPrint('ApiClient: createBulkTables called with count: $count');
      final response = await _dio.post(
        ApiConst.createBulkTables,
        data: {'count': count},
      );
      debugPrint('ApiClient: Bulk tables created successfully');
      return response.data['tables'] as List<dynamic>;
    } on DioException catch (e) {
      debugPrint('ApiClient: createBulkTables failed with error: ${e.message}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      final errorData = e.response?.data;
      if (errorData is Map<String, dynamic>) {
        throw errorData['error'] ??
            errorData['message'] ??
            e.message ??
            'Failed to create bulk tables';
      }
      throw e.message ?? 'Failed to create bulk tables';
    }
  }

  Future<dynamic> getTableDetail(String id) async {
    try {
      debugPrint('ApiClient: getTableDetail called with id: $id');
      final response = await _dio.get(
        ApiConst.getTableDetail.replaceAll('{id}', id),
      );
      debugPrint('ApiClient: Table detail retrieved successfully');
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient: getTableDetail failed with error: ${e.message}');
      throw e.message ?? 'Failed to get table detail';
    }
  }

  Future<dynamic> updateTable(String id, Map<String, dynamic> request) async {
    try {
      debugPrint('ApiClient: updateTable called with id: $id, data: $request');
      final response = await _dio.put(
        ApiConst.updateTable.replaceAll('{id}', id),
        data: request,
      );
      debugPrint('ApiClient: Table updated successfully');
      return response.data;
    } on DioException catch (e) {
      debugPrint('ApiClient: updateTable failed with error: ${e.message}');
      throw e.message ?? 'Failed to update table';
    }
  }

  Future<void> deleteTable(String id) async {
    try {
      debugPrint('ApiClient: deleteTable called with id: $id');
      await _dio.delete(ApiConst.deleteTable.replaceAll('{id}', id));
      debugPrint('ApiClient: Table deleted successfully');
    } on DioException catch (e) {
      debugPrint('ApiClient: deleteTable failed with error: ${e.message}');
      throw e.message ?? 'Failed to delete table';
    }
  }

  Future<dynamic> regenerateTableQR(String id) async {
    try {
      debugPrint('ApiClient: regenerateTableQR called with id: $id');
      final response = await _dio.post(
        ApiConst.regenerateTableQR.replaceAll('{id}', id),
      );
      debugPrint('ApiClient: QR code regenerated successfully');
      return response.data;
    } on DioException catch (e) {
      debugPrint(
        'ApiClient: regenerateTableQR failed with error: ${e.message}',
      );
      throw e.message ?? 'Failed to regenerate QR code';
    }
  }

  // ============================================================================
  // STAFF ENDPOINTS
  // ============================================================================

  Future<StaffListResponse> getStaffList() async {
    try {
      debugPrint('ApiClient: Fetching staff list...');
      final response = await _dio.get(ApiConst.listStaff);
      debugPrint('ApiClient: Staff list fetched successfully');
      return StaffListResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('ApiClient: getStaffList failed with error: ${e.message}');
      throw e.message ?? 'Failed to fetch staff list';
    }
  }

  Future<StaffInvitationResponse> createStaffInvitation(
    CreateStaffInvitationRequest request,
  ) async {
    try {
      debugPrint('ApiClient: Creating staff invitation...');
      debugPrint('ApiClient: Request data: ${request.toJson()}');
      final response = await _dio.post(
        ApiConst.createStaffInvite,
        data: request.toJson(),
      );
      debugPrint('ApiClient: Staff invitation created successfully');
      return StaffInvitationResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint(
        'ApiClient: createStaffInvitation failed with error: ${e.message}',
      );
      debugPrint('ApiClient: Response status: ${e.response?.statusCode}');
      debugPrint('ApiClient: Response data: ${e.response?.data}');
      throw e.message ?? 'Failed to create staff invitation';
    }
  }

  Future<StaffInvitationListResponse> getStaffInvitations() async {
    try {
      debugPrint('ApiClient: Fetching staff invitations...');
      final response = await _dio.get(ApiConst.listStaffInvites);
      debugPrint('ApiClient: Staff invitations fetched successfully');
      debugPrint('ApiClient: Raw response data: ${response.data}');
      return StaffInvitationListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint(
        'ApiClient: getStaffInvitations failed with error: ${e.message}',
      );
      throw e.message ?? 'Failed to fetch staff invitations';
    } catch (e) {
      debugPrint('ApiClient: getStaffInvitations parsing error: $e');
      rethrow;
    }
  }

  Future<void> removeStaff(int staffId) async {
    try {
      debugPrint('ApiClient: Removing staff member with ID: $staffId');
      await _dio.delete(
        ApiConst.removeStaff.replaceAll('{staffId}', staffId.toString()),
      );
      debugPrint('ApiClient: Staff member removed successfully');
    } on DioException catch (e) {
      debugPrint('ApiClient: removeStaff failed with error: ${e.message}');
      throw e.message ?? 'Failed to remove staff member';
    }
  }

  Future<StaffStatusToggleResponse> toggleStaffStatus(
    int staffId,
    StaffStatusToggleRequest request,
  ) async {
    try {
      debugPrint('ApiClient: Toggling staff status for ID: $staffId');
      final response = await _dio.patch(
        ApiConst.toggleStaffStatus.replaceAll('{staffId}', staffId.toString()),
        data: request.toJson(),
      );
      debugPrint('ApiClient: Staff status toggled successfully');
      return StaffStatusToggleResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      debugPrint(
        'ApiClient: toggleStaffStatus failed with error: ${e.message}',
      );
      throw e.message ?? 'Failed to toggle staff status';
    }
  }

  Future<void> deleteStaffInvitation(String inviteId) async {
    try {
      debugPrint('ApiClient: Deleting staff invitation with ID: $inviteId');
      await _dio.delete(
        ApiConst.deleteStaffInvite.replaceAll('{inviteId}', inviteId),
      );
      debugPrint('ApiClient: Staff invitation deleted successfully');
    } on DioException catch (e) {
      debugPrint(
        'ApiClient: deleteStaffInvitation failed with error: ${e.message}',
      );
      throw e.message ?? 'Failed to delete staff invitation';
    }
  }
}
