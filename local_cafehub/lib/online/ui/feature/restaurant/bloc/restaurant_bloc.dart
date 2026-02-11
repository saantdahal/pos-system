import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:bhansa_ghar/online/core/repositories/restaurant_repository.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant.dart';
import 'package:bhansa_ghar/online/core/services/user_friendly_response_service.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantBloc({required RestaurantRepository restaurantRepository})
    : _restaurantRepository = restaurantRepository,
      super(RestaurantInitial()) {
    on<LoadRestaurantEvent>(_onLoadRestaurant);
    on<UpdateRestaurantEvent>(_onUpdateRestaurant);
  }

  Future<void> _onLoadRestaurant(
    LoadRestaurantEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());
    try {
      final restaurant = await _restaurantRepository.getRestaurant();
      debugPrint(
        '🔍 RESTAURANT DATA FROM BACKEND (Load): ${restaurant.toJson()}',
      );
      debugPrint('📋 Restaurant Details:');
      debugPrint('   - ID: ${restaurant.id}');
      debugPrint('   - Name: ${restaurant.name}');
      debugPrint('   - Type: ${restaurant.type?.displayName ?? "Unknown"}');
      debugPrint('   - Address: ${restaurant.address}');
      debugPrint('   - Latitude: ${restaurant.latitude}');
      debugPrint('   - Longitude: ${restaurant.longitude}');
      debugPrint('   - Phone: ${restaurant.phone}');
      debugPrint('   - Description: ${restaurant.description}');
      debugPrint('   - Tables Capacity: ${restaurant.tablesCapacity}');
      debugPrint('   - Is Active: ${restaurant.isActive}');

      emit(RestaurantLoaded(restaurant: restaurant));
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(RestaurantError(message: errorMessage));
    }
  }

  Future<void> _onUpdateRestaurant(
    UpdateRestaurantEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantUpdating());
    try {
      final response = await _restaurantRepository.updateRestaurant(
        event.request,
      );
      // Reload restaurant after update
      final updatedRestaurant = await _restaurantRepository.getRestaurant();
      debugPrint(
        '🔄 RESTAURANT DATA FROM BACKEND (Update): ${updatedRestaurant.toJson()}',
      );
      debugPrint('📋 Updated Restaurant Details:');
      debugPrint('   - ID: ${updatedRestaurant.id}');
      debugPrint('   - Name: ${updatedRestaurant.name}');
      debugPrint(
        '   - Type: ${updatedRestaurant.type?.displayName ?? "Unknown"}',
      );
      debugPrint('   - Address: ${updatedRestaurant.address}');
      debugPrint('   - Latitude: ${updatedRestaurant.latitude}');
      debugPrint('   - Longitude: ${updatedRestaurant.longitude}');
      debugPrint('   - Phone: ${updatedRestaurant.phone}');
      debugPrint('   - Description: ${updatedRestaurant.description}');
      debugPrint('   - Tables Capacity: ${updatedRestaurant.tablesCapacity}');
      debugPrint('   - Is Active: ${updatedRestaurant.isActive}');
      emit(
        RestaurantUpdated(
          restaurant: updatedRestaurant,
          message: response['message'] ?? 'Restaurant updated successfully',
        ),
      );
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(RestaurantError(message: errorMessage));
    }
  }
}
