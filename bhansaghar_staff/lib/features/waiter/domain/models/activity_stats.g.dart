// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityStats _$ActivityStatsFromJson(Map<String, dynamic> json) =>
    ActivityStats(
      totalActivities: (json['total_activities'] as num).toInt(),
      activitiesToday: (json['activities_today'] as num).toInt(),
      recentActivities: (json['recent_activities'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      activityBreakdown:
          Map<String, int>.from(json['activity_breakdown'] as Map),
    );

Map<String, dynamic> _$ActivityStatsToJson(ActivityStats instance) =>
    <String, dynamic>{
      'total_activities': instance.totalActivities,
      'activities_today': instance.activitiesToday,
      'recent_activities': instance.recentActivities,
      'activity_breakdown': instance.activityBreakdown,
    };
