import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_type.dart';
import 'restaurant_setup_form_state.dart';

class RestaurantSetupFormCubit extends Cubit<RestaurantSetupFormState> {
  final AuthRepository _authRepository;

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  RestaurantSetupFormCubit({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const RestaurantSetupFormState());

  void updateSelectedType(String typeId) {
    emit(state.copyWith(selectedRestaurantTypeId: typeId));
  }

  void updateDescription(String description) {
    descriptionController.text = description;
    emit(state.copyWith(description: description));
  }

  void updateTableCapacity(double capacity) {
    emit(state.copyWith(tableCapacity: capacity));
  }

  void updateOpeningTime(TimeOfDay time) {
    emit(state.copyWith(openingTime: time));
  }

  void updateClosingTime(TimeOfDay time) {
    emit(state.copyWith(closingTime: time));
  }

  void updateRestaurantName(String name) {
    emit(state.copyWith(restaurantNameFromProfile: name));
  }

  void updateRestaurantAddress(String address) {
    emit(state.copyWith(restaurantAddressFromProfile: address));
  }

  void updateRestaurantPhone(String phone) {
    emit(state.copyWith(restaurantPhoneFromProfile: phone));
  }

  void updateRestaurantTypes(List<RestaurantType> types) {
    emit(state.copyWith(restaurantTypes: types));
    if (types.isNotEmpty && state.selectedRestaurantTypeId.isEmpty) {
      emit(state.copyWith(selectedRestaurantTypeId: types.first.id.toString()));
    }
  }

  Future<void> loadProfileData() async {
    emit(state.copyWith(isLoadingProfile: true, errorMessage: null));
    try {
      final profileData = await _authRepository.getProfileData();
      final email = await _authRepository.getUserEmail();
      if (profileData != null) {
        final name = profileData['restaurantName'] as String?;
        final phone = profileData['phone'] as String?;
        final address = profileData['address'] as String?;

        nameController.text = name ?? '';
        phoneController.text = phone ?? '';
        addressController.text = address ?? '';

        emit(
          state.copyWith(
            restaurantNameFromProfile: name,
            restaurantPhoneFromProfile: phone,
            restaurantAddressFromProfile: address,
            restaurantLatitudeFromProfile: profileData['latitude'] as double?,
            restaurantLongitudeFromProfile: profileData['longitude'] as double?,
            email: email,
            isLoadingProfile: false,
          ),
        );
      } else {
        emit(state.copyWith(isLoadingProfile: false, email: email));
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingProfile: false,
          errorMessage: 'Error loading profile data: $e',
        ),
      );
    }
  }

  Future<void> initializeWithWidgetData({
    String? restaurantName,
    String? restaurantPhone,
    String? restaurantAddress,
    double? restaurantLatitude,
    double? restaurantLongitude,
  }) async {
    final email = await _authRepository.getUserEmail();
    if (restaurantName != null ||
        restaurantPhone != null ||
        restaurantAddress != null ||
        restaurantLatitude != null ||
        restaurantLongitude != null) {
      nameController.text = restaurantName ?? '';
      phoneController.text = restaurantPhone ?? '';
      addressController.text = restaurantAddress ?? '';

      emit(
        state.copyWith(
          restaurantNameFromProfile: restaurantName,
          restaurantPhoneFromProfile: restaurantPhone,
          restaurantAddressFromProfile: restaurantAddress,
          restaurantLatitudeFromProfile: restaurantLatitude,
          restaurantLongitudeFromProfile: restaurantLongitude,
          email: email,
        ),
      );
    } else {
      await loadProfileData();
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }
}
