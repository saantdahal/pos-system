import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../domain/models/activity.dart';
import '../../../domain/models/activity_stats.dart';
import '../../../domain/repositories/activity_repository.dart';

part 'activities_event.dart';
part 'activities_state.dart';

class WaiterActivitiesBloc
    extends Bloc<WaiterActivitiesEvent, WaiterActivitiesState> {
  final ActivityRepository activityRepository;

  WaiterActivitiesBloc({required this.activityRepository})
    : super(WaiterActivitiesInitial()) {
    on<FetchTodayActivitiesEvent>(_onFetchTodayActivities);
    on<FetchUserActivitiesEvent>(_onFetchUserActivities);
    on<FetchActivityStatsEvent>(_onFetchActivityStats);
    on<RefreshActivitiesEvent>(_onRefreshActivities);
  }

  /// Fetch today's activities
  Future<void> _onFetchTodayActivities(
    FetchTodayActivitiesEvent event,
    Emitter<WaiterActivitiesState> emit,
  ) async {
    emit(WaiterActivitiesLoading());
    try {
      final activities = await activityRepository.getTodayActivities();

      if (activities.isEmpty) {
        emit(WaiterActivitiesEmpty());
      } else {
        emit(WaiterActivitiesLoaded(activities: activities));
      }
    } catch (e) {
      emit(WaiterActivitiesError(message: e.toString()));
    }
  }

  /// Fetch user activities with filtering
  Future<void> _onFetchUserActivities(
    FetchUserActivitiesEvent event,
    Emitter<WaiterActivitiesState> emit,
  ) async {
    emit(WaiterActivitiesLoading());
    try {
      final activities = await activityRepository.getUserActivities(
        days: event.days,
        activityType: event.activityType,
      );

      if (activities.isEmpty) {
        emit(WaiterActivitiesEmpty());
      } else {
        emit(WaiterActivitiesLoaded(activities: activities));
      }
    } catch (e) {
      emit(WaiterActivitiesError(message: e.toString()));
    }
  }

  /// Fetch activity statistics
  Future<void> _onFetchActivityStats(
    FetchActivityStatsEvent event,
    Emitter<WaiterActivitiesState> emit,
  ) async {
    emit(WaiterActivitiesLoading());
    try {
      final stats = await activityRepository.getActivityStats(days: event.days);
      emit(WaiterActivitiesStatsLoaded(stats: stats));
    } catch (e) {
      emit(WaiterActivitiesError(message: e.toString()));
    }
  }

  /// Refresh activities (fetch today's activities again)
  Future<void> _onRefreshActivities(
    RefreshActivitiesEvent event,
    Emitter<WaiterActivitiesState> emit,
  ) async {
    try {
      final activities = await activityRepository.getTodayActivities();

      if (activities.isEmpty) {
        emit(WaiterActivitiesEmpty());
      } else {
        emit(WaiterActivitiesLoaded(activities: activities));
      }
    } catch (e) {
      emit(WaiterActivitiesError(message: e.toString()));
    }
  }
}
