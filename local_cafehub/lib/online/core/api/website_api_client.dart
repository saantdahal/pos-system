import 'package:dio/dio.dart';
import 'package:bhansa_ghar/online/core/models/website/website_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class WebsiteApiClient {
  final Dio _dio;

  WebsiteApiClient(this._dio);

  /// Get website data for the authenticated user's restaurant
  Future<WebsiteData> getWebsiteData() async {
    try {
      debugPrint('WebsiteApiClient: Fetching website data...');
      final response = await _dio.get('core/website/data/');

      if (response.statusCode == 200) {
        final data = WebsiteData.fromJson(
          response.data as Map<String, dynamic>,
        );
        debugPrint('WebsiteApiClient: Website data fetched successfully');
        return data;
      } else {
        throw Exception('Failed to fetch website data: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('WebsiteApiClient: Error fetching website data: ${e.message}');
      rethrow;
    }
  }

  /// Update website data for the authenticated user's restaurant
  Future<WebsiteData> updateWebsiteData(WebsiteData websiteData) async {
    try {
      debugPrint('WebsiteApiClient: Updating website data...');
      final response = await _dio.put(
        'core/website/data/',
        data: websiteData.toJson(),
      );

      if (response.statusCode == 200) {
        final data = WebsiteData.fromJson(
          response.data as Map<String, dynamic>,
        );
        debugPrint('WebsiteApiClient: Website data updated successfully');
        return data;
      } else {
        throw Exception(
          'Failed to update website data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('WebsiteApiClient: Error updating website data: ${e.message}');
      rethrow;
    }
  }

  /// Get public website data for a restaurant (no auth required)
  Future<WebsiteData> getPublicWebsiteData(String restaurantSlug) async {
    try {
      debugPrint(
        'WebsiteApiClient: Fetching public website data for $restaurantSlug...',
      );
      final response = await _dio.get('core/website/$restaurantSlug/');

      if (response.statusCode == 200) {
        final data = WebsiteData.fromJson(
          response.data as Map<String, dynamic>,
        );
        debugPrint(
          'WebsiteApiClient: Public website data fetched successfully',
        );
        return data;
      } else {
        throw Exception(
          'Failed to fetch public website data: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint(
        'WebsiteApiClient: Error fetching public website data: ${e.message}',
      );
      rethrow;
    }
  }

  /// Upload website image (logo, favicon, about_image, hero_image)
  /// Returns the image URL from the server
  Future<String> uploadWebsiteImage(File imageFile, String imageType) async {
    try {
      debugPrint(
        'WebsiteApiClient: Uploading website image of type: $imageType',
      );

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
        'image_type': imageType,
      });

      final response = await _dio.post(
        'core/website/upload-image/',
        data: formData,
        onSendProgress: (int sent, int total) {
          debugPrint(
            'WebsiteApiClient: Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
          );
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final imageUrl = response.data['image_url'] as String;
        debugPrint('WebsiteApiClient: Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('WebsiteApiClient: Error uploading image: ${e.message}');
      rethrow;
    }
  }
}
