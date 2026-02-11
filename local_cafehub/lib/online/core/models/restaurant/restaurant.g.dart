// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map<String, dynamic> json) => Restaurant(
      id: json['id'] as String?,
      name: json['name'] as String?,
      type: json['type'] == null
          ? null
          : RestaurantType.fromJson(json['type'] as Map<String, dynamic>),
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      phone: json['phone'] as String?,
      description: json['description'] as String?,
      tablesCapacity: (json['tablesCapacity'] as num?)?.toInt(),
      operatingHours: json['operating_hours'] as Map<String, dynamic>?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'description': instance.description,
      'tablesCapacity': instance.tablesCapacity,
      'operating_hours': instance.operatingHours,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
    };

RestaurantUpdateRequest _$RestaurantUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    RestaurantUpdateRequest(
      name: json['name'] as String,
      type: (json['type'] as num).toInt(),
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      phone: json['phone'] as String,
      description: json['description'] as String?,
      operatingHours: json['operating_hours'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$RestaurantUpdateRequestToJson(
        RestaurantUpdateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone': instance.phone,
      'description': instance.description,
      'operating_hours': instance.operatingHours,
    };
