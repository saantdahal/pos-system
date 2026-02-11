import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'restaurant_type.g.dart';

@JsonSerializable()
class RestaurantType extends Equatable {
  final int? id;
  final String? name;
  @JsonKey(name: 'display_name')
  final String? displayName;

  const RestaurantType({this.id, this.name, this.displayName});

  factory RestaurantType.fromJson(Map<String, dynamic> json) =>
      _$RestaurantTypeFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantTypeToJson(this);

  @override
  List<Object?> get props => [id, name, displayName];
}
