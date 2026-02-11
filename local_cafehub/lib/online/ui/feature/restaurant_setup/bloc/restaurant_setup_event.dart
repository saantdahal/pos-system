import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_request.dart';

abstract class RestaurantSetupEvent extends Equatable {
  const RestaurantSetupEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load restaurant types
class LoadRestaurantTypesRequested extends RestaurantSetupEvent {}

/// Event to create a restaurant
class CreateRestaurantRequested extends RestaurantSetupEvent {
  final RestaurantRequest request;

  const CreateRestaurantRequested(this.request);

  @override
  List<Object?> get props => [request];
}

/// Event to clear error state
class ClearErrorRequested extends RestaurantSetupEvent {
  const ClearErrorRequested();
}

/// Event to reset the restaurant setup state
class ResetRestaurantSetup extends RestaurantSetupEvent {
  const ResetRestaurantSetup();
}
