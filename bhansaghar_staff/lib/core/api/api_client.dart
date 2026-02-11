import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:bhansaghar_staff/core/api/api_const.dart';
import 'package:bhansaghar_staff/core/models/profile/user_profile.dart';
import 'package:bhansaghar_staff/core/models/profile/profile_update_request.dart';
import 'package:bhansaghar_staff/core/models/profile/email_update_request.dart';

class ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClient(this._dio, {required this.baseUrl}) {
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('🌐 FRONTEND: Making GET request to: $baseUrl$endpoint');
      debugPrint('📤 FRONTEND: Query parameters: $queryParameters');
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      debugPrint('📥 FRONTEND: Response status: ${response.statusCode}');
      debugPrint('📥 FRONTEND: Response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ FRONTEND: DioException in GET: ${e.message}');
      debugPrint('❌ FRONTEND: DioException type: ${e.type}');
      debugPrint('❌ FRONTEND: DioException response: ${e.response?.data}');
      debugPrint(
        '❌ FRONTEND: DioException status code: ${e.response?.statusCode}',
      );
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('🌐 FRONTEND: Making POST request to: $baseUrl$endpoint');
      debugPrint('📤 FRONTEND: Request data: $data');
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      debugPrint('📥 FRONTEND: Response status: ${response.statusCode}');
      debugPrint('📥 FRONTEND: Response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ FRONTEND: DioException in POST: ${e.message}');
      debugPrint('❌ FRONTEND: DioException response: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('🌐 FRONTEND: Making PATCH request to: $baseUrl$endpoint');
      debugPrint('📤 FRONTEND: Request data: $data');
      final response = await _dio.patch(
        endpoint,
        data: data,
        queryParameters: queryParameters,
      );
      debugPrint('📥 FRONTEND: Response status: ${response.statusCode}');
      debugPrint('📥 FRONTEND: Response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ FRONTEND: DioException in PATCH: ${e.message}');
      debugPrint('❌ FRONTEND: DioException type: ${e.type}');
      debugPrint('❌ FRONTEND: DioException response: ${e.response?.data}');
      debugPrint(
        '❌ FRONTEND: DioException status code: ${e.response?.statusCode}',
      );
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      debugPrint('🌐 FRONTEND: Making DELETE request to: $baseUrl$endpoint');
      final response = await _dio.delete(
        endpoint,
        queryParameters: queryParameters,
      );
      debugPrint('📥 FRONTEND: Response status: ${response.statusCode}');
      debugPrint('📥 FRONTEND: Response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ FRONTEND: DioException in DELETE: ${e.message}');
      debugPrint('❌ FRONTEND: DioException type: ${e.type}');
      debugPrint('❌ FRONTEND: DioException response: ${e.response?.data}');
      debugPrint(
        '❌ FRONTEND: DioException status code: ${e.response?.statusCode}',
      );
      throw _handleError(e);
    }
  }

  Future<dynamic> patchWithFile(
    String endpoint, {
    required Map<String, dynamic> data,
    String? avatarPath,
  }) async {
    try {
      debugPrint(
        '🌐 FRONTEND: Making PATCH request (with file) to: $baseUrl$endpoint',
      );

      if (avatarPath != null && avatarPath.isNotEmpty) {
        debugPrint('📸 FRONTEND: Uploading with image');
        final imageFile = File(avatarPath);
        if (!await imageFile.exists()) {
          throw Exception('Image file does not exist: $avatarPath');
        }
        debugPrint(
          '📸 FRONTEND: Image file exists at: $avatarPath, size: ${await imageFile.length()} bytes',
        );

        final formData = FormData.fromMap(data);
        formData.files.add(
          MapEntry('avatar', await MultipartFile.fromFile(avatarPath)),
        );

        debugPrint('📤 FRONTEND: Sending PATCH request with FormData');
        final response = await _dio.patch(endpoint, data: formData);
        debugPrint('📥 FRONTEND: Response status: ${response.statusCode}');
        debugPrint('📥 FRONTEND: Response data: ${response.data}');
        return response.data;
      } else {
        debugPrint('📝 FRONTEND: Updating without image');
        final response = await _dio.patch(endpoint, data: data);
        debugPrint('📥 FRONTEND: Response status: ${response.statusCode}');
        debugPrint('📥 FRONTEND: Response data: ${response.data}');
        return response.data;
      }
    } on DioException catch (e) {
      debugPrint('❌ FRONTEND: DioException in PATCH with file: ${e.message}');
      debugPrint('❌ FRONTEND: DioException type: ${e.type}');
      debugPrint('❌ FRONTEND: DioException response: ${e.response?.data}');
      debugPrint(
        '❌ FRONTEND: DioException status code: ${e.response?.statusCode}',
      );
      throw _handleError(e);
    }
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

  Exception _handleError(DioException error) {
    String message = 'Unknown error';
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      message = data['message'] ?? error.message ?? 'Unknown error';
    } else if (data is String) {
      message = data;
    } else if (error.message != null) {
      message = error.message!;
    }

    debugPrint('🔴 ERROR DETAILS:');
    debugPrint('   Type: ${error.type}');
    debugPrint('   Message: $message');
    debugPrint('   Status Code: ${error.response?.statusCode}');
    debugPrint('   Full Response: ${error.response?.data}');
    if (error.error != null) {
      debugPrint('   Error: ${error.error}');
    }

    return Exception(message);
  }
}
