import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile {
  final int id;
  final String username;
  final String email;
  final String? googleId;
  final bool? isGoogleVerified;
  final bool? isEmailVerified;
  final bool? profileCompleted;
  final String? role;
  final String? phone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? avatar;
  final RestaurantInfo? restaurant;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.googleId,
    this.isGoogleVerified,
    this.isEmailVerified,
    this.profileCompleted,
    this.role,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.avatar,
    this.restaurant,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class RestaurantInfo {
  final String id;
  final String name;
  final RestaurantTypeInfo? type;

  RestaurantInfo({required this.id, required this.name, this.type});

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) =>
      _$RestaurantInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantInfoToJson(this);
}

@JsonSerializable()
class RestaurantTypeInfo {
  final String name;
  @JsonKey(name: 'display_name')
  final String displayName;

  RestaurantTypeInfo({required this.name, required this.displayName});

  factory RestaurantTypeInfo.fromJson(Map<String, dynamic> json) =>
      _$RestaurantTypeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantTypeInfoToJson(this);
}
