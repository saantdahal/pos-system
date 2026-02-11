// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantRequest _$RestaurantRequestFromJson(Map<String, dynamic> json) =>
    RestaurantRequest(
      email: json['email'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      tablesCapacity: (json['tables_capacity'] as num?)?.toInt(),
      operatingHours: (json['operating_hours'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, Map<String, String>.from(e as Map)),
      ),
    );

Map<String, dynamic> _$RestaurantRequestToJson(RestaurantRequest instance) =>
    <String, dynamic>{
      'email': instance.email,
      'name': instance.name,
      'type': instance.type,
      'phone': instance.phone,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'tables_capacity': instance.tablesCapacity,
      'operating_hours': instance.operatingHours,
    };
