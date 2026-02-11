import 'package:bhansaghar_staff/core/services/dio_service.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Global navigator key for showing dialogs from interceptor
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthInterceptor extends Interceptor {
  final DioService dioService;
  final Box<String> tokenBox;

  AuthInterceptor(this.dioService, this.tokenBox);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final accessToken = tokenBox.get('access_token');
    debugPrint(
      '🔑 AUTH_INTERCEPTOR: Requesting ${options.method} ${options.path}',
    );
    debugPrint('🔑 AUTH_INTERCEPTOR: Full URL: ${options.uri}');
    if (accessToken != null) {
      debugPrint(
        '🔑 AUTH_INTERCEPTOR: Adding token to headers: ${accessToken.substring(0, 5)}...',
      );
      options.headers['Authorization'] = 'Bearer $accessToken';
      debugPrint('🔑 AUTH_INTERCEPTOR: Token added successfully');
    } else {
      debugPrint('🔑 AUTH_INTERCEPTOR: ⚠️ No access token found in box!');
    }
    debugPrint('🔑 AUTH_INTERCEPTOR: Final headers: ${options.headers}');
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('🔴 AUTH_INTERCEPTOR: Error occurred');
    debugPrint('   Path: ${err.requestOptions.path}');
    debugPrint('   Status Code: ${err.response?.statusCode}');
    debugPrint('   Error Type: ${err.type}');
    debugPrint('   Error Message: ${err.message}');

    if (err.response?.statusCode == 401) {
      // Token expired, try refresh
      final refreshTokenToken = tokenBox.get('refresh_token');
      if (refreshTokenToken != null) {
        try {
          // Create a new Dio instance to avoid circular dependency/loop
          final refreshDio = Dio(BaseOptions(baseUrl: dioService.baseUrl));

          final String refreshEndpoint = 'core/token/refresh/';

          debugPrint(
            '🔑 AUTH_INTERCEPTOR: Attempting token refresh at: ${dioService.baseUrl}$refreshEndpoint',
          );

          final response = await refreshDio.post(
            refreshEndpoint,
            data: {'refresh': refreshTokenToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['access'];
            debugPrint(
              '🔑 AUTH_INTERCEPTOR: Refresh successful, retrying request...',
            );
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
          debugPrint('🔑 AUTH_INTERCEPTOR: Refresh failed: $e');

          // Show user-friendly dialog
          _showSessionExpiredDialog();

          // Trigger logout
          dioService.logoutCallback?.call();
        }
      } else {
        // No refresh token, user needs to login
        debugPrint('🔑 AUTH_INTERCEPTOR: ⚠️ No refresh token found');
        _showSessionExpiredDialog();
        dioService.logoutCallback?.call();
      }
    }
    handler.next(err);
  }

  void _showSessionExpiredDialog() {
    // Get the context from the current navigator
    final context = _getActiveContext();

    if (context != null) {
      debugPrint('📱 AUTH_INTERCEPTOR: Showing session expired dialog');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.orange),
                SizedBox(width: 12),
                Text('Session Expired'),
              ],
            ),
            content: const Text(
              'Your session has expired. Please log in again to continue.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to login - this will be handled by logout callback
                },
                child: const Text(
                  'Log In Again',
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            ],
          );
        },
      );
    } else {
      debugPrint('⚠️ AUTH_INTERCEPTOR: Could not find context to show dialog');
    }
  }

  BuildContext? _getActiveContext() {
    try {
      return navigatorKey.currentContext;
    } catch (e) {
      debugPrint('⚠️ AUTH_INTERCEPTOR: Error getting context: $e');
      return null;
    }
  }
}
