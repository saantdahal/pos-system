import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_request.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_response.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_type.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant.dart';
import 'package:flutter/material.dart';

class RestaurantRepository {
  final ApiClient _apiClient;

  RestaurantRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Create a new restaurant
  Future<RestaurantResponse> createRestaurant(RestaurantRequest request) async {
    try {
      debugPrint(
        'RestaurantRepository: createRestaurant called with name: ${request.name}',
      );
      final response = await _apiClient.createRestaurant(request);
      debugPrint(
        'RestaurantRepository: Restaurant created successfully: ${response.restaurant}',
      );
      return response;
    } catch (e) {
      debugPrint('RestaurantRepository: Error creating restaurant: $e');
      rethrow;
    }
  }

  /// Get restaurant details for the current user (owner)
  Future<Restaurant> getRestaurant() async {
    try {
      debugPrint('RestaurantRepository: getRestaurant called');
      final restaurant = await _apiClient.getRestaurant();
      debugPrint(
        'RestaurantRepository: Retrieved restaurant: ${restaurant.name}',
      );
      return restaurant;
    } catch (e) {
      debugPrint('RestaurantRepository: Error getting restaurant: $e');
      rethrow;
    }
  }

  /// Update restaurant details
  Future<Map<String, dynamic>> updateRestaurant(
    RestaurantUpdateRequest request,
  ) async {
    try {
      debugPrint('RestaurantRepository: updateRestaurant called');
      final response = await _apiClient.updateRestaurant(request);
      debugPrint('RestaurantRepository: Restaurant updated successfully');
      return response;
    } catch (e) {
      debugPrint('RestaurantRepository: Error updating restaurant: $e');
      rethrow;
    }
  }

  /// Get all restaurant types
  Future<List<RestaurantType>> getRestaurantTypes() async {
    try {
      debugPrint('RestaurantRepository: getRestaurantTypes called');
      final types = await _apiClient.getRestaurantTypes();
      debugPrint(
        'RestaurantRepository: Retrieved ${types.length} restaurant types',
      );
      return types;
    } catch (e) {
      debugPrint('RestaurantRepository: Error getting restaurant types: $e');
      rethrow;
    }
  }
}
