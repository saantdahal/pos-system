// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertModel _$AlertModelFromJson(Map<String, dynamic> json) => AlertModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      type: $enumDecode(_$AlertTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool,
      actionUrl: json['action_url'] as String?,
    );

Map<String, dynamic> _$AlertModelToJson(AlertModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': _$AlertTypeEnumMap[instance.type]!,
      'created_at': instance.createdAt.toIso8601String(),
      'is_read': instance.isRead,
      'action_url': instance.actionUrl,
    };

const _$AlertTypeEnumMap = {
  AlertType.table: 'table',
  AlertType.order: 'order',
  AlertType.kitchen: 'kitchen',
  AlertType.system: 'system',
};
