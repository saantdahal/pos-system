// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAuthResponse _$GoogleAuthResponseFromJson(Map<String, dynamic> json) =>
    GoogleAuthResponse(
      message: json['message'] as String,
      email: json['email'] as String,
      verificationSent: json['verification_sent'] as bool,
      verificationCode: json['verification_code'] as String?,
      userStatus: (json['user_status'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as bool),
      ),
      profileData: json['profile_data'] as Map<String, dynamic>?,
      access: json['access'] as String?,
      refresh: json['refresh'] as String?,
    );

Map<String, dynamic> _$GoogleAuthResponseToJson(GoogleAuthResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'email': instance.email,
      'verification_sent': instance.verificationSent,
      'verification_code': instance.verificationCode,
      'user_status': instance.userStatus,
      'profile_data': instance.profileData,
      'access': instance.access,
      'refresh': instance.refresh,
    };
