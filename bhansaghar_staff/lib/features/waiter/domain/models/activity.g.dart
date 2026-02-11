// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      id: json['id'] as String,
      user: (json['user'] as num).toInt(),
      userName: json['user_name'] as String,
      userRole: json['user_role'] as String,
      restaurant: (json['restaurant'] as num?)?.toInt(),
      activityType: json['activity_type'] as String,
      activityTypeDisplay: json['activity_type_display'] as String,
      description: json['description'] as String,
      relatedObjectType: json['related_object_type'] as String?,
      relatedObjectId: json['related_object_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'id': instance.id,
      'user': instance.user,
      'user_name': instance.userName,
      'user_role': instance.userRole,
      'restaurant': instance.restaurant,
      'activity_type': instance.activityType,
      'activity_type_display': instance.activityTypeDisplay,
      'description': instance.description,
      'related_object_type': instance.relatedObjectType,
      'related_object_id': instance.relatedObjectId,
      'metadata': instance.metadata,
      'created_at': instance.createdAt.toIso8601String(),
    };
