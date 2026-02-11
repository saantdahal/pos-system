import 'package:dio/dio.dart';

import '../models/activity.dart';
import '../models/activity_stats.dart';

class ActivityRepository {
  final Dio _dio;

  ActivityRepository({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch activities from today
  Future<List<Activity>> getTodayActivities() async {
    try {
      final response = await _dio.get('/core/activities/today/');
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List;

      return results
          .map((item) => Activity.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch user activities with optional filters
  Future<List<Activity>> getUserActivities({
    int days = 30,
    String? activityType,
  }) async {
    try {
      final params = <String, dynamic>{'days': days};
      if (activityType != null) {
        params['activity_type'] = activityType;
      }

      final response = await _dio.get(
        '/core/activities/',
        queryParameters: params,
      );
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List;

      return results
          .map((item) => Activity.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch activity statistics
  Future<ActivityStats> getActivityStats({int days = 7}) async {
    try {
      final response = await _dio.get(
        '/core/activities/stats/',
        queryParameters: {'days': days},
      );
      return ActivityStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle DioException and convert to user-friendly error messages
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 401:
            return 'Unauthorized. Please log in again.';
          case 403:
            return 'You do not have permission to view this.';
          case 404:
            return 'Activity log not found.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'Error: ${e.message}';
        }
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Certificate error. Please check your connection.';
      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case DioExceptionType.unknown:
        return 'Unknown error occurred: ${e.message}';
    }
  }
}
