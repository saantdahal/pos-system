// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileResponse _$ProfileResponseFromJson(Map<String, dynamic> json) =>
    ProfileResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      restaurant: json['restaurant'] as Map<String, dynamic>?,
      readyForDashboard: json['ready_for_dashboard'] as bool?,
    );

Map<String, dynamic> _$ProfileResponseToJson(ProfileResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'access': instance.access,
      'refresh': instance.refresh,
      'user': instance.user,
      'restaurant': instance.restaurant,
      'ready_for_dashboard': instance.readyForDashboard,
    };
