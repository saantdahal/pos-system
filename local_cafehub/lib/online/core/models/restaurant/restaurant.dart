import 'package:json_annotation/json_annotation.dart';
import 'restaurant_type.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  final String? id;
  final String? name;
  final RestaurantType? type;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? phone;
  final String? description;
  final int? tablesCapacity;

  @JsonKey(name: 'operating_hours')
  final Map<String, dynamic>? operatingHours;

  final bool? isActive;
  final String? createdAt;

  Restaurant({
    this.id,
    this.name,
    this.type,
    this.address,
    this.latitude,
    this.longitude,
    this.phone,
    this.description,
    this.tablesCapacity,
    this.operatingHours,
    this.isActive,
    this.createdAt,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
}

@JsonSerializable()
class RestaurantUpdateRequest {
  final String name;
  final int type;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final String? description;

  @JsonKey(name: 'operating_hours')
  final Map<String, dynamic>? operatingHours;

  RestaurantUpdateRequest({
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    this.description,
    this.operatingHours,
  });

  factory RestaurantUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$RestaurantUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantUpdateRequestToJson(this);
}
