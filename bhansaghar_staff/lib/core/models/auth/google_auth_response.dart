import 'package:json_annotation/json_annotation.dart';

part 'google_auth_response.g.dart';

@JsonSerializable()
class GoogleAuthResponse {
  final String message;
  final String email;
  @JsonKey(name: 'verification_sent')
  final bool verificationSent;
  @JsonKey(name: 'verification_code')
  final String? verificationCode;
  @JsonKey(name: 'user_status')
  final Map<String, bool>? userStatus;
  @JsonKey(name: 'profile_data')
  final Map<String, dynamic>? profileData;
  final String? access;
  final String? refresh;

  GoogleAuthResponse({
    required this.message,
    required this.email,
    required this.verificationSent,
    this.verificationCode,
    this.userStatus,
    this.profileData,
    this.access,
    this.refresh,
  });

  factory GoogleAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleAuthResponseToJson(this);
}
