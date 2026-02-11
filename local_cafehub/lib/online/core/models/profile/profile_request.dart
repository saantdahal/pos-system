import 'package:json_annotation/json_annotation.dart';

part 'profile_request.g.dart';

@JsonSerializable()
class ProfileRequest {
  final String email;
  final String username;
  final String phone; 
  final String address;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'restaurant_name')
  final String restaurantName;

  ProfileRequest({
    required this.email,
    required this.username,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.restaurantName,
  });

  factory ProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$ProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileRequestToJson(this);
}
