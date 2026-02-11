// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmailUpdateRequest _$EmailUpdateRequestFromJson(Map<String, dynamic> json) =>
    EmailUpdateRequest(
      newEmail: json['new_email'] as String,
    );

Map<String, dynamic> _$EmailUpdateRequestToJson(EmailUpdateRequest instance) =>
    <String, dynamic>{
      'new_email': instance.newEmail,
    };

EmailVerifyRequest _$EmailVerifyRequestFromJson(Map<String, dynamic> json) =>
    EmailVerifyRequest(
      otp: json['otp'] as String,
    );

Map<String, dynamic> _$EmailVerifyRequestToJson(EmailVerifyRequest instance) =>
    <String, dynamic>{
      'otp': instance.otp,
    };
