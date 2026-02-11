import 'package:json_annotation/json_annotation.dart';

part 'email_update_request.g.dart';

@JsonSerializable()
class EmailUpdateRequest {
  @JsonKey(name: 'new_email')
  final String newEmail;

  EmailUpdateRequest({required this.newEmail});

  factory EmailUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmailUpdateRequestToJson(this);
}

@JsonSerializable()
class EmailVerifyRequest {
  final String otp;

  EmailVerifyRequest({required this.otp});

  factory EmailVerifyRequest.fromJson(Map<String, dynamic> json) =>
      _$EmailVerifyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$EmailVerifyRequestToJson(this);
}
