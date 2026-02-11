import 'package:bhansa_ghar/online/core/api/website_api_client.dart';
import 'package:bhansa_ghar/online/core/models/website/website_model.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class WebsiteRepository {
  final WebsiteApiClient _apiClient;

  WebsiteRepository(this._apiClient);

  /// Get website data for the authenticated user's restaurant
  Future<WebsiteData> getWebsiteData() async {
    try {
      debugPrint('WebsiteRepository: Getting website data...');
      return await _apiClient.getWebsiteData();
    } catch (e) {
      debugPrint('WebsiteRepository: Error getting website data: $e');
      rethrow;
    }
  }

  /// Update website data
  Future<WebsiteData> updateWebsiteData(WebsiteData websiteData) async {
    try {
      debugPrint('WebsiteRepository: Updating website data...');
      return await _apiClient.updateWebsiteData(websiteData);
    } catch (e) {
      debugPrint('WebsiteRepository: Error updating website data: $e');
      rethrow;
    }
  }

  /// Get public website data
  Future<WebsiteData> getPublicWebsiteData(String restaurantSlug) async {
    try {
      debugPrint(
        'WebsiteRepository: Getting public website data for $restaurantSlug...',
      );
      return await _apiClient.getPublicWebsiteData(restaurantSlug);
    } catch (e) {
      debugPrint('WebsiteRepository: Error getting public website data: $e');
      rethrow;
    }
  }

  /// Upload website image (logo, favicon, about_image)
  /// Returns the image URL from the server
  Future<String> uploadWebsiteImage(File imageFile, String imageType) async {
    try {
      debugPrint(
        'WebsiteRepository: Uploading website image of type: $imageType',
      );
      return await _apiClient.uploadWebsiteImage(imageFile, imageType);
    } catch (e) {
      debugPrint('WebsiteRepository: Error uploading website image: $e');
      rethrow;
    }
  }
}
