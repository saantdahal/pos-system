// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
      message: json['message'] as String?,
      userStatus: (json['user_status'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      nextStep: json['next_step'] as String?,
    );

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access': instance.access,
      'refresh': instance.refresh,
      'message': instance.message,
      'user_status': instance.userStatus,
      'next_step': instance.nextStep,
    };
