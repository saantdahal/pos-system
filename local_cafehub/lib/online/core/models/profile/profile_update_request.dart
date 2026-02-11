import 'package:json_annotation/json_annotation.dart';

part 'profile_update_request.g.dart';

@JsonSerializable()
class ProfileUpdateRequest {
  final String? username;
  final String? phone;
  final String? address;
  final String? avatar;

  ProfileUpdateRequest({this.username, this.phone, this.address, this.avatar});

  factory ProfileUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileUpdateRequestToJson(this);
}
