import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String? access;
  final String? refresh;
  final String? message;
  @JsonKey(name: 'user_status')
  final Map<String, bool>? userStatus;
  @JsonKey(name: 'next_step')
  final String? nextStep;

  AuthResponse({
    this.access,
    this.refresh,
    this.message,
    this.userStatus,
    this.nextStep,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
