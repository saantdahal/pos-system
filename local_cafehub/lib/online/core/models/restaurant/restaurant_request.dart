import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restaurant_request.g.dart';

@JsonSerializable()
class RestaurantRequest extends Equatable {
  final String email;
  final String name;
  final String type;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  @JsonKey(name: 'tables_capacity')
  final int? tablesCapacity;
  @JsonKey(name: 'operating_hours')
  final Map<String, Map<String, String>>? operatingHours;

  const RestaurantRequest({
    required this.email,
    required this.name,
    required this.type,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.tablesCapacity,
    this.operatingHours,
  });

  factory RestaurantRequest.fromJson(Map<String, dynamic> json) =>
      _$RestaurantRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantRequestToJson(this);

  @override
  List<Object?> get props => [
    email,
    name,
    type,
    phone,
    address,
    latitude,
    longitude,
    description,
    tablesCapacity,
    operatingHours,
  ];
}
