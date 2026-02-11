import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DioService {
  static const String tokenBoxName = 'auth_tokens';

  final Dio _dio;
  late Box<String> _tokenBox;
  final String baseUrl;
  Function? logoutCallback;

  DioService(this._dio, {String? customBaseUrl})
    : baseUrl = customBaseUrl ?? '' {
    try {
      debugPrint('DioService initialized');
      _initializeDio();
    } catch (e, stack) {
      debugPrint('ERROR in DioService: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> _initializeTokenBox() async {
    if (Hive.isBoxOpen(tokenBoxName)) {
      _tokenBox = Hive.box<String>(tokenBoxName);
    } else {
      _tokenBox = await Hive.openBox<String>(tokenBoxName);
    }
  }

  void _initializeDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  Future<void> setTokens(String accessToken, String refreshToken) async {
    debugPrint('💾 DIO_SERVICE: Saving new tokens...');
    await _initializeTokenBox();
    await _tokenBox.put('access_token', accessToken);
    await _tokenBox.put('refresh_token', refreshToken);
    debugPrint('💾 DIO_SERVICE: Tokens saved successfully');
  }

  Future<void> clearTokens() async {
    await _initializeTokenBox();
    await _tokenBox.clear();
  }

  Future<String?> getRefreshToken() async {
    await _initializeTokenBox();
    return _tokenBox.get('refresh_token');
  }

  Dio get dio => _dio;
}
