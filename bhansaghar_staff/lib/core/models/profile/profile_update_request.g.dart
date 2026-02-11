// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileUpdateRequest _$ProfileUpdateRequestFromJson(
        Map<String, dynamic> json) =>
    ProfileUpdateRequest(
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$ProfileUpdateRequestToJson(
        ProfileUpdateRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'phone': instance.phone,
      'address': instance.address,
      'avatar': instance.avatar,
    };
