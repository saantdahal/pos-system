import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restaurant_response.g.dart';

@JsonSerializable()
class RestaurantResponse extends Equatable {
  final bool? success;
  final Map<String, dynamic>? restaurant;
  final String? message;
  final String? access;
  final String? refresh;

  const RestaurantResponse({
    this.success,
    this.restaurant,
    this.message,
    this.access,
    this.refresh,
  });

  factory RestaurantResponse.fromJson(Map<String, dynamic> json) =>
      _$RestaurantResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantResponseToJson(this);

  @override
  List<Object?> get props => [success, restaurant, message, access, refresh];
}
