part of 'restaurant_bloc.dart';

@immutable
sealed class RestaurantEvent {}

/// Event to load restaurant details
final class LoadRestaurantEvent extends RestaurantEvent {}

/// Event to update restaurant details
final class UpdateRestaurantEvent extends RestaurantEvent {
  final RestaurantUpdateRequest request;

  UpdateRestaurantEvent({required this.request});
}
