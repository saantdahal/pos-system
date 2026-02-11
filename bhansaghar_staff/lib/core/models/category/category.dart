import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? restaurant;
  final int? position;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  Category({
    required this.id,
    required this.name,
    this.restaurant,
    this.position,
    this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  Category copyWith({
    int? id,
    String? name,
    String? restaurant,
    int? position,
    String? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      restaurant: restaurant ?? this.restaurant,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Category(id: $id, name: $name, restaurant: $restaurant, position: $position, createdAt: $createdAt)';
}
