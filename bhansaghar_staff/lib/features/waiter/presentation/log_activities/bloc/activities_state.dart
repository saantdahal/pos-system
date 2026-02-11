part of 'activities_bloc.dart';

@immutable
sealed class WaiterActivitiesState {}

final class WaiterActivitiesInitial extends WaiterActivitiesState {}

final class WaiterActivitiesLoading extends WaiterActivitiesState {}

final class WaiterActivitiesLoaded extends WaiterActivitiesState {
  final List<Activity> activities;

  WaiterActivitiesLoaded({required this.activities});
}

final class WaiterActivitiesStatsLoaded extends WaiterActivitiesState {
  final ActivityStats stats;

  WaiterActivitiesStatsLoaded({required this.stats});
}

final class WaiterActivitiesError extends WaiterActivitiesState {
  final String message;

  WaiterActivitiesError({required this.message});
}

final class WaiterActivitiesEmpty extends WaiterActivitiesState {}
