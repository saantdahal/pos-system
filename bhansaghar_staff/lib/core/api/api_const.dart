// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConst {
  // Base URL for API endpoints - now handled by DioService
  // static String get baseUrl =>
  //     dotenv.env['BaseUrl'] ?? 'http://10.0.2.2:8000/api/';

  // Authentication endpoints
  static const String googleAuth = 'core/auth/google/';

  // Profile endpoints
  static const String getProfile = 'core/profile/staff/';
  static const String updateProfile = 'core/profile/staff/';
  static const String requestEmailUpdate = 'core/profile/update-email/request/';
  static const String verifyEmailUpdate = 'core/profile/update-email/verify/';

  // Token endpoints
  static const String refreshToken = 'core/token/refresh/';

  // Role endpoints
  // Role/Mode endpoints
  static const String selectMode = 'core/mode/select/';

  // Table endpoints
  static const String listTables = 'restaurants/tables/';
  static const String createTable = 'restaurants/tables/';
  static const String createBulkTables = 'restaurants/tables/create_bulk/';
  static const String getTableDetail = 'restaurants/tables/{id}/';
  static const String updateTable = 'restaurants/tables/{id}/';
  static const String deleteTable = 'restaurants/tables/{id}/';
  static const String regenerateTableQR =
      'restaurants/tables/{id}/regenerate_qr/';
  static const String scanTableQR = 'restaurants/tables/scan-qr/';
}
