// import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConst {
  // Base URL for API endpoints - now handled by DioService
  // static String get baseUrl =>
  //     dotenv.env['BaseUrl'] ?? 'http://10.0.2.2:8000/api/';

  // Authentication endpoints
  static const String googleAuth = 'core/auth/google/';
  static const String verifyOtp = 'core/auth/verify-code/';
  static const String resendOtp = 'core/auth/resend-code/';
  static const String sendVerificationCode = 'core/auth/send-code/';

  // Profile endpoints
  static const String completeProfile = 'core/profile/complete/';
  static const String getProfile = 'core/profile/';
  static const String updateProfile = 'core/profile/';
  static const String updateMode = 'core/profile/update-mode/';
  static const String requestEmailUpdate = 'core/profile/update-email/request/';
  static const String verifyEmailUpdate = 'core/profile/update-email/verify/';

  // Token endpoints
  static const String refreshToken = 'core/token/refresh/';

  // User endpoints
  static const String testUser = 'core/test/';
  static const String adminStatus = 'core/status/';

  // Role endpoints
  // Role/Mode endpoints
  static const String selectMode = 'core/mode/select/';

  // Restaurant endpoints
  static const String createRestaurant = 'restaurants/create/';
  static const String getRestaurantTypes = 'restaurants/restaurant-types/';
  static const String getRestaurant = 'restaurants/my-restaurant/';
  static const String updateRestaurant = 'restaurants/update/';

  // Category endpoints
  static const String listCategories = 'restaurants/categories/';
  static const String createCategory = 'restaurants/categories/';
  static const String getCategoryDetail = 'restaurants/categories/{id}/';
  static const String updateCategory = 'restaurants/categories/{id}/';
  static const String deleteCategory = 'restaurants/categories/{id}/';

  // Menu Item endpoints
  static const String listMenuItems = 'restaurants/menu-items/';
  static const String createMenuItem = 'restaurants/menu-items/';
  static const String getMenuItemDetail = 'restaurants/menu-items/{id}/';
  static const String updateMenuItem = 'restaurants/menu-items/{id}/';
  static const String deleteMenuItem = 'restaurants/menu-items/{id}/';

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

  // Staff endpoints
  static const String createStaffInvite = 'restaurants/staff-invite/';
  static const String listStaffInvites = 'restaurants/staff-invites/';
  static const String claimStaffInvite = 'restaurants/claim-invite/{inviteId}/';
  static const String listStaff = 'restaurants/staff/';
  static const String removeStaff = 'restaurants/staff/{staffId}/';
  static const String toggleStaffStatus =
      'restaurants/staff/{staffId}/toggle-status/';
  static const String deleteStaffInvite =
      'restaurants/staff-invite/{inviteId}/';
}
