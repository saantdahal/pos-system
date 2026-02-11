// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      googleId: json['googleId'] as String?,
      isGoogleVerified: json['isGoogleVerified'] as bool?,
      isEmailVerified: json['isEmailVerified'] as bool?,
      profileCompleted: json['profileCompleted'] as bool?,
      role: json['role'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      avatar: json['avatar'] as String?,
      restaurant: json['restaurant'] == null
          ? null
          : RestaurantInfo.fromJson(json['restaurant'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'googleId': instance.googleId,
      'isGoogleVerified': instance.isGoogleVerified,
      'isEmailVerified': instance.isEmailVerified,
      'profileCompleted': instance.profileCompleted,
      'role': instance.role,
      'phone': instance.phone,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'avatar': instance.avatar,
      'restaurant': instance.restaurant,
    };

RestaurantInfo _$RestaurantInfoFromJson(Map<String, dynamic> json) =>
    RestaurantInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] == null
          ? null
          : RestaurantTypeInfo.fromJson(json['type'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RestaurantInfoToJson(RestaurantInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
    };

RestaurantTypeInfo _$RestaurantTypeInfoFromJson(Map<String, dynamic> json) =>
    RestaurantTypeInfo(
      name: json['name'] as String,
      displayName: json['display_name'] as String,
    );

Map<String, dynamic> _$RestaurantTypeInfoToJson(RestaurantTypeInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'display_name': instance.displayName,
    };
