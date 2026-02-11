import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

// Custom converter for handling string-to-int conversions
class IntFromString implements JsonConverter<int, dynamic> {
  const IntFromString();

  @override
  int fromJson(dynamic json) {
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) {
      try {
        return int.parse(json);
      } catch (e) {
        debugPrint('❌ IntFromString failed to parse: $json');
        return 0;
      }
    }
    return 0;
  }

  @override
  dynamic toJson(int object) => object;
}

@JsonSerializable()
class CategoryModel extends Equatable {
  @IntFromString()
  final int id;
  final String name;
  final String? description;
  final bool? isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, isActive];
}
