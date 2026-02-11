// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemModel _$MenuItemModelFromJson(Map<String, dynamic> json) =>
    MenuItemModel(
      id: const IntFromString().fromJson(json['id']),
      category: const IntFromString().fromJson(json['category']),
      name: json['name'] as String,
      description: json['description'] as String,
      basePrice: const DoubleFromString().fromJson(json['base_price']),
      discountPercentage: json['discount_percentage'] == null
          ? 0.0
          : const DoubleFromString().fromJson(json['discount_percentage']),
      stockQuantity:
          const IntFromStringNullable().fromJson(json['stock_quantity']),
      position: const IntFromString().fromJson(json['position']),
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$MenuItemModelToJson(MenuItemModel instance) =>
    <String, dynamic>{
      'id': _$JsonConverterToJson<dynamic, int>(
          instance.id, const IntFromString().toJson),
      'category': const IntFromString().toJson(instance.category),
      'name': instance.name,
      'description': instance.description,
      'base_price': const DoubleFromString().toJson(instance.basePrice),
      'discount_percentage':
          const DoubleFromString().toJson(instance.discountPercentage),
      'stock_quantity':
          const IntFromStringNullable().toJson(instance.stockQuantity),
      'position': const IntFromString().toJson(instance.position),
      'image': instance.image,
      'image_url': instance.imageUrl,
      'isActive': instance.isActive,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
