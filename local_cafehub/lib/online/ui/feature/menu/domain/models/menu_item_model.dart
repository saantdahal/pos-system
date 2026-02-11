import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'menu_item_model.g.dart';

// Custom converters for handling string-to-number conversions
class DoubleFromString implements JsonConverter<double, dynamic> {
  const DoubleFromString();

  @override
  double fromJson(dynamic json) {
    if (json is double) return json;
    if (json is int) return json.toDouble();
    if (json is String) {
      try {
        return double.parse(json);
      } catch (e) {
        debugPrint('❌ DoubleFromString failed to parse: $json');
        return 0.0;
      }
    }
    return 0.0;
  }

  @override
  dynamic toJson(double object) => object;
}

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

class IntFromStringNullable implements JsonConverter<int?, dynamic> {
  const IntFromStringNullable();

  @override
  int? fromJson(dynamic json) {
    if (json == null) return null;
    if (json is int) return json;
    if (json is double) return json.toInt();
    if (json is String) {
      try {
        return int.parse(json);
      } catch (e) {
        debugPrint('❌ IntFromStringNullable failed to parse: $json');
        return null;
      }
    }
    return null;
  }

  @override
  dynamic toJson(int? object) => object;
}

@JsonSerializable()
class MenuItemModel extends Equatable {
  @IntFromString()
  final int? id;
  @IntFromString()
  final int category;
  final String name;
  final String description;
  @JsonKey(name: 'base_price')
  @DoubleFromString()
  final double basePrice;
  @JsonKey(name: 'discount_percentage')
  @DoubleFromString()
  final double discountPercentage;
  @JsonKey(name: 'stock_quantity')
  @IntFromStringNullable()
  final int? stockQuantity;
  @IntFromString()
  final int position;
  final String? image;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  final bool? isActive;

  const MenuItemModel({
    this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.basePrice,
    this.discountPercentage = 0.0,
    this.stockQuantity,
    required this.position,
    this.image,
    this.imageUrl,
    this.isActive = true,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) =>
      _$MenuItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$MenuItemModelToJson(this);

  MenuItemModel copyWith({
    int? id,
    int? category,
    String? name,
    String? description,
    double? basePrice,
    double? discountPercentage,
    int? stockQuantity,
    int? position,
    String? image,
    String? imageUrl,
    bool? isActive,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      position: position ?? this.position,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  double get finalPrice => basePrice * (1 - (discountPercentage / 100));
  bool get isUnlimited => stockQuantity == null;
  bool get isOutOfStock => stockQuantity == 0;
  bool get isLowStock => (stockQuantity ?? 0) > 0 && (stockQuantity ?? 0) < 5;
  bool get isAvailable => isUnlimited || (stockQuantity ?? 0) > 0;

  @override
  List<Object?> get props => [
    id,
    category,
    name,
    description,
    basePrice,
    discountPercentage,
    stockQuantity,
    position,
    image,
    imageUrl,
    isActive,
  ];
}
