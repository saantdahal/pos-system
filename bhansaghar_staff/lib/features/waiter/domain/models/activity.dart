import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

@JsonSerializable()
class Activity {
  final String id;
  final int user;
  @JsonKey(name: 'user_name')
  final String userName;
  @JsonKey(name: 'user_role')
  final String userRole;
  final int? restaurant;
  @JsonKey(name: 'activity_type')
  final String activityType;
  @JsonKey(name: 'activity_type_display')
  final String activityTypeDisplay;
  final String description;
  @JsonKey(name: 'related_object_type')
  final String? relatedObjectType;
  @JsonKey(name: 'related_object_id')
  final String? relatedObjectId;
  final Map<String, dynamic>? metadata;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.user,
    required this.userName,
    required this.userRole,
    this.restaurant,
    required this.activityType,
    required this.activityTypeDisplay,
    required this.description,
    this.relatedObjectType,
    this.relatedObjectId,
    this.metadata,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  @override
  String toString() =>
      'Activity(id: $id, type: $activityTypeDisplay, desc: $description)';
}
