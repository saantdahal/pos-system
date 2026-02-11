import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_response.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_type.dart';

abstract class RestaurantSetupState extends Equatable {
  const RestaurantSetupState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class RestaurantSetupInitial extends RestaurantSetupState {
  const RestaurantSetupInitial();
}

/// Loading state when creating restaurant
class RestaurantSetupLoading extends RestaurantSetupState {
  const RestaurantSetupLoading();
}

/// Success state when restaurant is created
class RestaurantSetupSuccess extends RestaurantSetupState {
  final RestaurantResponse response;

  const RestaurantSetupSuccess(this.response);

  @override
  List<Object?> get props => [response];
}

/// Failure state when restaurant creation fails
class RestaurantSetupFailure extends RestaurantSetupState {
  final String message;

  const RestaurantSetupFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when loading restaurant types
class RestaurantTypesLoading extends RestaurantSetupState {
  const RestaurantTypesLoading();
}

/// State when restaurant types are loaded
class RestaurantTypesLoaded extends RestaurantSetupState {
  final List<RestaurantType> types;

  const RestaurantTypesLoaded(this.types);

  @override
  List<Object?> get props => [types];
}

/// State when loading restaurant types failed
class RestaurantTypesError extends RestaurantSetupState {
  final String message;

  const RestaurantTypesError(this.message);

  @override
  List<Object?> get props => [message];
}
