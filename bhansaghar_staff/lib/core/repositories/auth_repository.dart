import 'package:bhansaghar_staff/core/api/api_client.dart';
import 'package:bhansaghar_staff/core/models/auth_models.dart';
import 'package:bhansaghar_staff/core/repositories/i_auth_repository.dart';
import 'package:bhansaghar_staff/core/services/dio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class AuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final DioService _dioService;
  final GoogleSignIn _googleSignIn;

  static const String authStateBoxName = 'auth_state';
  static const String keyUserEmail = 'user_email';
  static const String keyProfileCompleted = 'profile_completed';
  static const String keyUserRole = 'user_role';
  static const String keyAuthResponse = 'auth_response';
  static const String keyProfileData = 'profile_data';
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';

  AuthRepository({
    required ApiClient apiClient,
    required DioService dioService,
    GoogleSignIn? googleSignIn,
  }) : _apiClient = apiClient,
       _dioService = dioService,
       _googleSignIn = googleSignIn ?? GoogleSignIn() {
    debugPrint('AuthRepository created');
  }

  @override
  Future<void> setTokens(String access, String refresh) async {
    await _dioService.setTokens(access, refresh);
    final box = await _getAuthStateBox();
    await box.put(keyAccessToken, access);
    await box.put(keyRefreshToken, refresh);
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponse(
        accessToken: response['access_token'] ?? '',
        refreshToken: response['refresh_token'] ?? '',
        user: User(
          id: response['user']['id'] ?? '',
          email: response['user']['email'] ?? '',
          name: response['user']['name'] ?? '',
          role: _parseUserRole(response['user']['role']),
          isVerified: response['user']['is_verified'] ?? false,
          profileCompleted: response['user']['profile_completed'] ?? false,
        ),
      );

      await _saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  @override
  @override
  Future<AuthResponse> googleLogin() async {
    try {
      // Force account picker by signing out first (if already signed in)
      // This ensures the account selector is shown every time
      await _googleSignIn.signOut();

      debugPrint('🔐 Starting Google sign in with account picker...');
      final googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Google sign in cancelled by user');
        throw Exception('Google sign in cancelled');
      }

      debugPrint('✅ Google user selected: ${googleUser.email}');
      await googleUser.authentication;

      final response = await _apiClient.post(
        '/core/google-login/',
        data: {'google_id': googleUser.id, 'email': googleUser.email},
      );

      final authResponse = AuthResponse(
        accessToken: response['tokens']['access'],
        refreshToken: response['tokens']['refresh'],
        user: User(
          id: response['user']['id'].toString(),
          email: response['user']['email'],
          name: response['user']['username'],
          role: _parseUserRole(response['user']['role']),
          isVerified: true,
          profileCompleted: true,
        ),
      );

      await _saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      debugPrint('Google login error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> claimInviteWithQR({
    required String inviteId,
    GoogleSignInAccount? selectedAccount,
  }) async {
    debugPrint('🔍 claimInviteWithQR called with inviteId: $inviteId');
    try {
      debugPrint('🔐 Starting Google sign in...');

      // Use selected account if provided, otherwise start fresh sign-in
      GoogleSignInAccount? googleUser = selectedAccount;
      googleUser ??= await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('❌ Google sign in cancelled by user');
        throw Exception('Google sign in cancelled');
      }

      debugPrint('✅ Google sign in successful for: ${googleUser.email}');
      await googleUser.authentication;
      debugPrint('🔑 Got Google auth, user ID: ${googleUser.id}');

      debugPrint('📡 Making API call to /restaurants/claim-invite/$inviteId/');
      final response = await _apiClient.post(
        'restaurants/claim-invite/$inviteId/',
        data: {'google_id': googleUser.id, 'email': googleUser.email},
      );
      debugPrint('📨 API response received: $response');

      final authResponse = AuthResponse(
        accessToken: response['tokens']['access'],
        refreshToken: response['tokens']['refresh'],
        user: User(
          id: response['user']['id'].toString(),
          email: response['user']['email'],
          name: response['user']['username'],
          role: _parseUserRole(response['user']['role']),
          isVerified: true,
          profileCompleted: true,
        ),
      );

      await _saveAuthData(authResponse);
      debugPrint(
        '✅ Claim invite successful for user: ${authResponse.user.email}',
      );
      return authResponse;
    } catch (e) {
      debugPrint('❌ Claim invite error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> googleLoginFromQR({required String inviteId}) async {
    return claimInviteWithQR(inviteId: inviteId);
  }

  @override
  Future<String?> getInvitationEmail({required String inviteId}) async {
    try {
      debugPrint('🔍 Fetching invitation details for: $inviteId');
      final response = await _apiClient.get(
        '/restaurants/invite-details/$inviteId/',
      );

      debugPrint('📋 Raw response type: ${response.runtimeType}');
      debugPrint('📋 Raw response: $response');

      // Handle response - might be wrapped in 'data' or 'results'
      dynamic responseData = response;
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data')) {
          responseData = response['data'];
        } else if (response.containsKey('results')) {
          responseData = response['results'];
        }
      }

      debugPrint('📋 Response data: $responseData');

      if (responseData is Map<String, dynamic>) {
        final email = responseData['email'] as String?;
        debugPrint('📧 Got invitation email: $email');
        return email;
      } else {
        debugPrint('❌ Unexpected response format: ${responseData.runtimeType}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching invitation details: $e');
      return null;
    }
  }

  /// Get available Google accounts on device
  Future<List<GoogleSignInAccount>> getAvailableGoogleAccounts() async {
    try {
      debugPrint('🔍 Fetching available Google accounts...');
      final currentUser = await _googleSignIn.signInSilently();

      if (currentUser != null) {
        debugPrint('✅ Found signed-in account: ${currentUser.email}');
        return [currentUser];
      }

      // If no signed-in account, return empty list
      // User will need to go through full sign-in flow
      debugPrint('ℹ️ No currently signed-in account');
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching available Google accounts: $e');
      return [];
    }
  }

  /// Request user to select from available Google accounts
  Future<GoogleSignInAccount?> selectGoogleAccount(
    List<GoogleSignInAccount> availableAccounts,
  ) async {
    try {
      if (availableAccounts.isEmpty) {
        debugPrint('ℹ️ No available accounts, starting fresh sign-in');
        return await _googleSignIn.signIn();
      }

      if (availableAccounts.length == 1) {
        debugPrint(
          'ℹ️ Only one account available: ${availableAccounts[0].email}',
        );
        return availableAccounts[0];
      }

      // Multiple accounts available - let user select via UI
      // This method returns null; the UI should handle account selection
      return null;
    } catch (e) {
      debugPrint('❌ Error in selectGoogleAccount: $e');
      return null;
    }
  }

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'role': _userRoleToString(role),
        },
      );

      final authResponse = AuthResponse(
        accessToken: response['access_token'] ?? '',
        refreshToken: response['refresh_token'] ?? '',
        user: User(
          id: response['user']['id'] ?? '',
          email: response['user']['email'] ?? '',
          name: response['user']['name'] ?? '',
          role: _parseUserRole(response['user']['role']),
          isVerified: response['user']['is_verified'] ?? false,
          profileCompleted: response['user']['profile_completed'] ?? false,
        ),
      );

      await _saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      debugPrint('Register error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
      );

      final authResponse = AuthResponse(
        accessToken: response['access_token'] ?? '',
        refreshToken: response['refresh_token'] ?? '',
        user: User(
          id: response['user']['id'] ?? '',
          email: response['user']['email'] ?? '',
          name: response['user']['name'] ?? '',
          role: _parseUserRole(response['user']['role']),
          isVerified: response['user']['is_verified'] ?? true,
          profileCompleted: response['user']['profile_completed'] ?? false,
        ),
      );

      await _saveAuthData(authResponse);
      return authResponse;
    } catch (e) {
      debugPrint('OTP verification error: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final box = await _getAuthStateBox();
      return box.get(keyRefreshToken);
    } catch (e) {
      debugPrint('Error getting refresh token: $e');
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Get the refresh token before clearing local storage
      final refreshToken = await getRefreshToken();

      // Call backend logout endpoint to blacklist the refresh token
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          await _apiClient.post(
            '/core/logout/',
            data: {'refresh': refreshToken},
          );
          debugPrint('✅ Successfully logged out from backend');
        } catch (e) {
          debugPrint('⚠️ Failed to logout from backend: $e');
          // Continue with local logout even if backend call fails
        }
      }

      // Clear local tokens and storage
      await _dioService.clearTokens();
      final box = await _getAuthStateBox();
      await box.clear();
      await _googleSignIn.signOut();

      debugPrint('✅ Local logout completed');
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveUserRole(UserRole role) async {
    final box = await _getAuthStateBox();
    await box.put(keyUserRole, _userRoleToString(role));
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final box = await _getAuthStateBox();
      final userEmail = box.get(keyUserEmail);

      if (userEmail == null) return null;

      return User(
        id: box.get('user_id') ?? 'unknown',
        email: userEmail,
        name: box.get('user_name') ?? 'User',
        role: _parseUserRole(box.get(keyUserRole)),
        isVerified: (box.get('user_verified') ?? 'false') == 'true',
        profileCompleted: (box.get('profile_completed') ?? 'false') == 'true',
      );
    } catch (e) {
      debugPrint('Get current user error: $e');
      return null;
    }
  }

  Future<Box<String>> _getAuthStateBox() async {
    if (Hive.isBoxOpen(authStateBoxName)) {
      return Hive.box<String>(authStateBoxName);
    }
    return await Hive.openBox<String>(authStateBoxName);
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    final box = await _getAuthStateBox();
    await box.put(keyUserEmail, authResponse.user.email);
    await box.put(keyAccessToken, authResponse.accessToken);
    await box.put(keyRefreshToken, authResponse.refreshToken);
    await box.put('user_id', authResponse.user.id);
    await box.put('user_name', authResponse.user.name);
    await box.put(keyUserRole, _userRoleToString(authResponse.user.role));
    await box.put(
      'user_verified',
      authResponse.user.isVerified ? 'true' : 'false',
    );
    await box.put(
      'profile_completed',
      authResponse.user.profileCompleted ? 'true' : 'false',
    );

    debugPrint('✅ Auth data saved to local storage');
    debugPrint(
      '📋 Saved user: ${authResponse.user.email}, role: ${authResponse.user.role}',
    );
  }

  UserRole _parseUserRole(String? roleString) {
    if (roleString == null) return UserRole.unknown;
    switch (roleString.toLowerCase()) {
      case 'waiter':
        return UserRole.waiter;
      case 'kitchen':
        return UserRole.kitchen;
      default:
        return UserRole.unknown;
    }
  }

  String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.waiter:
        return 'waiter';
      case UserRole.kitchen:
        return 'kitchen';
      case UserRole.unknown:
        return 'unknown';
    }
  }

  // Save profile data from map (used when fetched from backend)
  Future<void> saveProfileDataFromMap(Map<String, dynamic> data) async {
    final box = await _getAuthStateBox();
    // Ensure keys match what we expect in getProfileData
    String? restaurantName;
    if (data['restaurant'] != null) {
      final restaurant = data['restaurant'];
      if (restaurant is Map<String, dynamic>) {
        restaurantName = restaurant['name'];
      } else {
        // Handle case where restaurant is an object with toJson() method
        try {
          final restaurantJson =
              (restaurant as dynamic).toJson() as Map<String, dynamic>;
          restaurantName = restaurantJson['name'];
        } catch (e) {
          debugPrint('Error extracting restaurant name: $e');
        }
      }
    }

    final profileData = {
      'restaurantName': restaurantName,
      'phone': data['phone'],
      'address': data['address'],
      'username': data['username'],
      'latitude': data['latitude'],
      'longitude': data['longitude'],
      'role': data['role'],
      'avatar': data['avatar'],
    };
    await box.put(keyProfileData, jsonEncode(profileData));
  }
}
