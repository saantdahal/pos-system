part of 'restaurant_bloc.dart';

@immutable
sealed class RestaurantState {}

/// Initial state before any data is loaded
final class RestaurantInitial extends RestaurantState {}

/// Loading state while fetching restaurant data
final class RestaurantLoading extends RestaurantState {}

/// Loaded state with restaurant data
final class RestaurantLoaded extends RestaurantState {
  final Restaurant restaurant;

  RestaurantLoaded({required this.restaurant});
}

/// Updating state while updating restaurant
final class RestaurantUpdating extends RestaurantState {}

/// Updated state after successful restaurant update
final class RestaurantUpdated extends RestaurantState {
  final Restaurant restaurant;
  final String message;

  RestaurantUpdated({required this.restaurant, required this.message});
}

/// Error state with error message
final class RestaurantError extends RestaurantState {
  final String message;

  RestaurantError({required this.message});
}
