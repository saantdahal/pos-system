// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileRequest _$ProfileRequestFromJson(Map<String, dynamic> json) =>
    ProfileRequest(
      email: json['email'] as String,
      username: json['username'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      restaurantName: json['restaurant_name'] as String,
    );

Map<String, dynamic> _$ProfileRequestToJson(ProfileRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'username': instance.username,
      'phone': instance.phone,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'restaurant_name': instance.restaurantName,
    };
