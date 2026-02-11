// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaiterProfileModel _$WaiterProfileModelFromJson(Map<String, dynamic> json) =>
    WaiterProfileModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      email: json['email'] as String,
      role: json['role'] as String,
      location: json['location'] as String,
      profileImageUrl: json['profile_image'] as String?,
      isVerified: json['is_verified'] as bool,
      ordersServedToday: (json['orders_served_today'] as num).toInt(),
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );

Map<String, dynamic> _$WaiterProfileModelToJson(WaiterProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'location': instance.location,
      'profile_image': instance.profileImageUrl,
      'is_verified': instance.isVerified,
      'orders_served_today': instance.ordersServedToday,
      'phone': instance.phone,
      'address': instance.address,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
    };
