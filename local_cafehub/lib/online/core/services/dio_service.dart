import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:bhansa_ghar/online/core/api/interceptors/auth_interceptor.dart';

class DioService {
  static const String tokenBoxName = 'auth_tokens';

  late Dio _dio;
  late Box<String> _tokenBox;
  late ApiClient _apiClient;
  final String baseUrl;

  DioService({required this.baseUrl}) {
    try {
      debugPrint('DioService constructor started');
      debugPrint('DioService: Using baseUrl = $baseUrl');
      _tokenBox = Hive.box<String>(tokenBoxName);
      debugPrint('Hive box obtained in DioService');
      _initializeDio();
      debugPrint('DioService constructor finished successfully');
    } catch (e, stack) {
      debugPrint('ERROR in DioService constructor: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        // Remove default Content-Type to allow Dio to set it automatically for FormData
      ),
    );

    _dio.interceptors.add(AuthInterceptor(this, _tokenBox));
    _apiClient = ApiClient(_dio, baseUrl: baseUrl);
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    await _tokenBox.put('access_token', accessToken);
    await _tokenBox.put('refresh_token', refreshToken);
  }

  Future<void> clearTokens() async {
    await _tokenBox.clear();
  }

  Dio get dio => _dio;
  ApiClient get client => _apiClient;
}
