// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaiterTable _$WaiterTableFromJson(Map<String, dynamic> json) => WaiterTable(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      status: $enumDecode(_$TableStatusEnumMap, json['status']),
      capacity: (json['capacity'] as num).toInt(),
      restaurantName: json['restaurant_name'] as String,
      lastUpdated: json['last_updated'] == null
          ? null
          : DateTime.parse(json['last_updated'] as String),
    );

Map<String, dynamic> _$WaiterTableToJson(WaiterTable instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _$TableStatusEnumMap[instance.status]!,
      'capacity': instance.capacity,
      'restaurant_name': instance.restaurantName,
      'last_updated': instance.lastUpdated?.toIso8601String(),
    };

const _$TableStatusEnumMap = {
  TableStatus.available: 'available',
  TableStatus.occupied: 'occupied',
  TableStatus.ready: 'ready',
  TableStatus.serving: 'serving',
  TableStatus.dirty: 'dirty',
};
