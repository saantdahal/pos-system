import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_type.dart';

class RestaurantSetupFormState extends Equatable {
  final String selectedRestaurantTypeId;
  final List<RestaurantType> restaurantTypes;
  final String description;
  final double tableCapacity;
  final TimeOfDay openingTime;
  final TimeOfDay closingTime;
  final String? restaurantNameFromProfile;
  final String? restaurantPhoneFromProfile;
  final String? restaurantAddressFromProfile;
  final double? restaurantLatitudeFromProfile;
  final double? restaurantLongitudeFromProfile;
  final String? email;
  final bool isLoadingProfile;
  final String? errorMessage;

  const RestaurantSetupFormState({
    this.selectedRestaurantTypeId = '',
    this.restaurantTypes = const [],
    this.description = '',
    this.tableCapacity = 25,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    this.restaurantNameFromProfile,
    this.restaurantPhoneFromProfile,
    this.restaurantAddressFromProfile,
    this.restaurantLatitudeFromProfile,
    this.restaurantLongitudeFromProfile,
    this.email,
    this.isLoadingProfile = false,
    this.errorMessage,
  }) : openingTime = openingTime ?? const TimeOfDay(hour: 10, minute: 0),
       closingTime = closingTime ?? const TimeOfDay(hour: 22, minute: 0);

  RestaurantSetupFormState copyWith({
    String? selectedRestaurantTypeId,
    List<RestaurantType>? restaurantTypes,
    String? description,
    double? tableCapacity,
    TimeOfDay? openingTime,
    TimeOfDay? closingTime,
    String? restaurantNameFromProfile,
    String? restaurantPhoneFromProfile,
    String? restaurantAddressFromProfile,
    double? restaurantLatitudeFromProfile,
    double? restaurantLongitudeFromProfile,
    String? email,
    bool? isLoadingProfile,
    String? errorMessage,
  }) {
    return RestaurantSetupFormState(
      selectedRestaurantTypeId:
          selectedRestaurantTypeId ?? this.selectedRestaurantTypeId,
      restaurantTypes: restaurantTypes ?? this.restaurantTypes,
      description: description ?? this.description,
      tableCapacity: tableCapacity ?? this.tableCapacity,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      restaurantNameFromProfile:
          restaurantNameFromProfile ?? this.restaurantNameFromProfile,
      restaurantPhoneFromProfile:
          restaurantPhoneFromProfile ?? this.restaurantPhoneFromProfile,
      restaurantAddressFromProfile:
          restaurantAddressFromProfile ?? this.restaurantAddressFromProfile,
      restaurantLatitudeFromProfile:
          restaurantLatitudeFromProfile ?? this.restaurantLatitudeFromProfile,
      restaurantLongitudeFromProfile:
          restaurantLongitudeFromProfile ?? this.restaurantLongitudeFromProfile,
      email: email ?? this.email,
      isLoadingProfile: isLoadingProfile ?? this.isLoadingProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    selectedRestaurantTypeId,
    restaurantTypes,
    description,
    tableCapacity,
    openingTime,
    closingTime,
    restaurantNameFromProfile,
    restaurantPhoneFromProfile,
    restaurantAddressFromProfile,
    restaurantLatitudeFromProfile,
    restaurantLongitudeFromProfile,
    email,
    isLoadingProfile,
    errorMessage,
  ];
}
