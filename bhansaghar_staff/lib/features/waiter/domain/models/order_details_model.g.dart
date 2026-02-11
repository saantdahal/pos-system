// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      status: json['status'] as String,
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'quantity': instance.quantity,
      'status': instance.status,
      'icon': instance.icon,
    };

OrderDetailsModel _$OrderDetailsModelFromJson(Map<String, dynamic> json) =>
    OrderDetailsModel(
      id: (json['id'] as num).toInt(),
      tableNumber: (json['table_number'] as num).toInt(),
      tableName: json['table_name'] as String,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (json['total_items'] as num).toInt(),
      servedItems: (json['served_items'] as num).toInt(),
      kitchenNotes: json['kitchen_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$OrderDetailsModelToJson(OrderDetailsModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'table_number': instance.tableNumber,
      'table_name': instance.tableName,
      'status': instance.status,
      'items': instance.items,
      'total_items': instance.totalItems,
      'served_items': instance.servedItems,
      'kitchen_notes': instance.kitchenNotes,
      'created_at': instance.createdAt.toIso8601String(),
    };
