part of 'activities_bloc.dart';

@immutable
sealed class WaiterActivitiesEvent {}

final class FetchTodayActivitiesEvent extends WaiterActivitiesEvent {}

final class FetchUserActivitiesEvent extends WaiterActivitiesEvent {
  final int days;
  final String? activityType;

  FetchUserActivitiesEvent({this.days = 30, this.activityType});
}

final class FetchActivityStatsEvent extends WaiterActivitiesEvent {
  final int days;

  FetchActivityStatsEvent({this.days = 7});
}

final class RefreshActivitiesEvent extends WaiterActivitiesEvent {}
