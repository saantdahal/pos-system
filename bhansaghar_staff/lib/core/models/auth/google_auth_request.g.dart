// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_auth_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleAuthRequest _$GoogleAuthRequestFromJson(Map<String, dynamic> json) =>
    GoogleAuthRequest(
      idToken: json['id_token'] as String,
    );

Map<String, dynamic> _$GoogleAuthRequestToJson(GoogleAuthRequest instance) =>
    <String, dynamic>{
      'id_token': instance.idToken,
    };
