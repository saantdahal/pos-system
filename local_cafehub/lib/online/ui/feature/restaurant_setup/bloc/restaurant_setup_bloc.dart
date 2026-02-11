import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/core/repositories/restaurant_repository.dart';
import 'restaurant_setup_event.dart';
import 'restaurant_setup_state.dart';

class RestaurantSetupBloc
    extends Bloc<RestaurantSetupEvent, RestaurantSetupState> {
  final RestaurantRepository _restaurantRepository;

  RestaurantSetupBloc({required RestaurantRepository restaurantRepository})
    : _restaurantRepository = restaurantRepository,
      super(const RestaurantSetupInitial()) {
    on<CreateRestaurantRequested>(_onCreateRestaurantRequested);
    on<ClearErrorRequested>(_onClearErrorRequested);
    on<ResetRestaurantSetup>(_onResetRestaurantSetup);
    on<LoadRestaurantTypesRequested>(_onLoadRestaurantTypesRequested);
  }

  /// Handle create restaurant request
  Future<void> _onCreateRestaurantRequested(
    CreateRestaurantRequested event,
    Emitter<RestaurantSetupState> emit,
  ) async {
    emit(const RestaurantSetupLoading());
    try {
      debugPrint(
        'RestaurantSetupBloc: Creating restaurant with name: ${event.request.name}',
      );
      final response = await _restaurantRepository.createRestaurant(
        event.request,
      );
      debugPrint('RestaurantSetupBloc: Restaurant created successfully');
      emit(RestaurantSetupSuccess(response));
    } catch (e) {
      debugPrint('RestaurantSetupBloc: Error creating restaurant: $e');
      final errorMessage = _parseErrorMessage(e.toString());
      emit(RestaurantSetupFailure(errorMessage));
    }
  }

  /// Handle clear error request
  Future<void> _onClearErrorRequested(
    ClearErrorRequested event,
    Emitter<RestaurantSetupState> emit,
  ) async {
    emit(const RestaurantSetupInitial());
  }

  /// Handle reset restaurant setup
  Future<void> _onResetRestaurantSetup(
    ResetRestaurantSetup event,
    Emitter<RestaurantSetupState> emit,
  ) async {
    emit(const RestaurantSetupInitial());
  }

  /// Parse error message from exception
  String _parseErrorMessage(String error) {
    // Handle specific error patterns from backend
    if (error.contains('OneToOneRel')) {
      return 'You already have a restaurant. Contact support to update it.';
    }
    if (error.contains('RestaurantCreateSerializer')) {
      return 'Invalid restaurant data. Please check all fields.';
    }
    if (error.contains('401') || error.contains('Unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    if (error.contains('400') || error.contains('Bad Request')) {
      return 'Invalid input. Please check all fields and try again.';
    }
    if (error.contains('500') || error.contains('Internal Server')) {
      return 'Server error. Please try again later.';
    }
    if (error.contains('Network') || error.contains('timeout')) {
      return 'Network error. Please check your connection.';
    }
    // Default error message
    return error.length > 100
        ? 'Failed to create restaurant. Please try again.'
        : error;
  }

  /// Handle load restaurant types request
  Future<void> _onLoadRestaurantTypesRequested(
    LoadRestaurantTypesRequested event,
    Emitter<RestaurantSetupState> emit,
  ) async {
    emit(const RestaurantTypesLoading());
    try {
      debugPrint('RestaurantSetupBloc: Loading restaurant types');
      final types = await _restaurantRepository.getRestaurantTypes();
      emit(RestaurantTypesLoaded(types));
    } catch (e) {
      debugPrint('RestaurantSetupBloc: Error loading restaurant types: $e');
      emit(RestaurantTypesError(_parseErrorMessage(e.toString())));
    }
  }
}
