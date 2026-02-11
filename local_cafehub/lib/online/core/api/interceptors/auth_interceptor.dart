import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
// import 'package:bhansa_ghar/online/core/api/api_const.dart';
import 'package:bhansa_ghar/online/core/services/dio_service.dart';

class AuthInterceptor extends Interceptor {
  final DioService dioService;
  final Box<String> tokenBox;

  AuthInterceptor(this.dioService, this.tokenBox);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = tokenBox.get('access_token');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, try refresh
      final refreshTokenToken = tokenBox.get('refresh_token');
      if (refreshTokenToken != null) {
        try {
          // Create a new Dio instance to avoid circular dependency/loop
          final refreshDio = Dio(BaseOptions(baseUrl: dioService.baseUrl));

          final response = await refreshDio.post(
            'core/token/refresh/',
            data: {'refresh': refreshTokenToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'];
            await tokenBox.put('access_token', newAccessToken);

            // Retry the original request
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            final clonedRequest = await dioService.dio.request(
              opts.path,
              options: Options(
                method: opts.method,
                headers: opts.headers,
                contentType: opts.contentType,
                responseType: opts.responseType,
              ),
              data: opts.data,
              queryParameters: opts.queryParameters,
            );

            handler.resolve(clonedRequest);
            return;
          }
        } catch (e) {
          // Refresh failed
          await dioService.clearTokens();
        }
      }
    }
    handler.next(err);
  }
}
