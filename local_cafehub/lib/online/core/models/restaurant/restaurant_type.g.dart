// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantType _$RestaurantTypeFromJson(Map<String, dynamic> json) =>
    RestaurantType(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      displayName: json['display_name'] as String?,
    );

Map<String, dynamic> _$RestaurantTypeToJson(RestaurantType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'display_name': instance.displayName,
    };
