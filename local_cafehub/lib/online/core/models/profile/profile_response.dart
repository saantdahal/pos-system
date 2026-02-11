import 'package:json_annotation/json_annotation.dart';

part 'profile_response.g.dart';

@JsonSerializable()
class ProfileResponse {
  final bool? success;
  final String? message;
  final String? access;
  final String? refresh;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? restaurant;
  @JsonKey(name: 'ready_for_dashboard')
  final bool? readyForDashboard;

  ProfileResponse({
    this.success,
    this.message,
    this.access,
    this.refresh,
    this.user,
    this.restaurant,
    this.readyForDashboard,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) =>
      _$ProfileResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);
}
