import 'package:json_annotation/json_annotation.dart';

part 'google_auth_request.g.dart';

@JsonSerializable()
class GoogleAuthRequest {
  @JsonKey(name: 'id_token')
  final String idToken;

  GoogleAuthRequest({required this.idToken});

  factory GoogleAuthRequest.fromJson(Map<String, dynamic> json) =>
      _$GoogleAuthRequestFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleAuthRequestToJson(this);
}
