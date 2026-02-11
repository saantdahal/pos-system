// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantResponse _$RestaurantResponseFromJson(Map<String, dynamic> json) =>
    RestaurantResponse(
      success: json['success'] as bool?,
      restaurant: json['restaurant'] as Map<String, dynamic>?,
      message: json['message'] as String?,
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
    );

Map<String, dynamic> _$RestaurantResponseToJson(RestaurantResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'restaurant': instance.restaurant,
      'message': instance.message,
      'access': instance.access,
      'refresh': instance.refresh,
    };
