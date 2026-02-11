import 'package:json_annotation/json_annotation.dart';

part 'activity_stats.g.dart';

@JsonSerializable()
class ActivityStats {
  @JsonKey(name: 'total_activities')
  final int totalActivities;
  @JsonKey(name: 'activities_today')
  final int activitiesToday;
  @JsonKey(name: 'recent_activities')
  final List<Map<String, dynamic>> recentActivities;
  @JsonKey(name: 'activity_breakdown')
  final Map<String, int> activityBreakdown;

  ActivityStats({
    required this.totalActivities,
    required this.activitiesToday,
    required this.recentActivities,
    required this.activityBreakdown,
  });

  factory ActivityStats.fromJson(Map<String, dynamic> json) =>
      _$ActivityStatsFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityStatsToJson(this);

  @override
  String toString() =>
      'ActivityStats(total: $totalActivities, today: $activitiesToday)';
}
