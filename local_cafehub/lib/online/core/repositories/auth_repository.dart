import 'dart:convert';
import 'package:bhansa_ghar/online/core/models/auth/google_auth_response.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bhansa_ghar/online/core/api/api_client.dart';
import 'package:bhansa_ghar/online/core/models/auth/google_auth_request.dart';
import 'package:bhansa_ghar/online/core/models/auth/auth_response.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_request.dart';
import 'package:bhansa_ghar/online/core/services/dio_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthRepository {
  final ApiClient _apiClient;
  final DioService _dioService;
  final GoogleSignIn _googleSignIn;

  static const String authStateBoxName = 'auth_state';
  static const String keyUserEmail = 'user_email';
  static const String keyOtpVerified = 'otp_verified';
  static const String keyProfileCompleted = 'profile_completed';
  static const String keyModeSelected = 'mode_selected';
  static const String keyAuthResponse = 'auth_response';
  static const String keyProfileData = 'profile_data';
  static const String keyRegistrationCompleted = 'registration_completed';

  AuthRepository({
    required ApiClient apiClient,
    required DioService dioService,
    GoogleSignIn? googleSignIn,
  }) : _apiClient = apiClient,
       _dioService = dioService,
       _googleSignIn = googleSignIn ?? GoogleSignIn() {
    debugPrint('AuthRepository created');
  }

  Future<void> setTokens(String access, String refresh) async {
    await _dioService.setTokens(access, refresh);
  }

  Future<Box<String>> _getAuthStateBox() async {
    if (Hive.isBoxOpen(authStateBoxName)) {
      return Hive.box<String>(authStateBoxName);
    }
    return await Hive.openBox<String>(authStateBoxName);
  }

  Future<GoogleAuthResponse> signInWithGoogle() async {
    try {
      debugPrint('AuthRepository: Attempting Google Sign-In...');
      // Clear previous sign-in to force account selection prompt
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        debugPrint('AuthRepository: Error during signOut: $e');
      }
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        debugPrint('AuthRepository: Google Sign-In cancelled by user');
        throw Exception('Google Sign-In cancelled');
      }

      debugPrint(
        'AuthRepository: Google Sign-In successful, account: ${account.email}',
      );
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        debugPrint('AuthRepository: Failed to get ID Token from Google');
        throw Exception('Failed to get ID Token');
      }

      debugPrint('AuthRepository: ID Token obtained, sending to backend...');
      final request = GoogleAuthRequest(idToken: idToken);
      final googleAuthResponse = await _apiClient.googleAuth(request);
      debugPrint(
        'AuthRepository: Backend authentication successful: ${googleAuthResponse.message}',
      );

      // Save the email for OTP verification flow
      await _saveUserEmail(googleAuthResponse.email);

      // If tokens are present, save them
      if (googleAuthResponse.access != null &&
          googleAuthResponse.refresh != null) {
        await setTokens(
          googleAuthResponse.access!,
          googleAuthResponse.refresh!,
        );
        // If we have tokens, it means we are at least partially authenticated.
        // We should also update other states based on userStatus if available.
        if (googleAuthResponse.userStatus != null) {
          final status = googleAuthResponse.userStatus!;
          await _setOtpVerified(status['is_email_verified'] ?? false);
          await _setProfileCompleted(status['profile_completed'] ?? false);
          // mode_selection_completed might be in status
          await _setModeSelected(status['mode_selection_completed'] ?? false);
          if (status['registration_completed'] == true) {
            await _setRegistrationCompleted(true);
          }
        }

        // Save profile data if available
        if (googleAuthResponse.profileData != null) {
          await saveProfileDataFromMap(googleAuthResponse.profileData!);
        }
      }

      // Return the response
      return googleAuthResponse;
    } on PlatformException catch (e) {
      debugPrint('AuthRepository: PlatformException during Google Sign-In');
      debugPrint('Code: ${e.code}');
      debugPrint('Message: ${e.message}');
      debugPrint('Details: ${e.details}');
      rethrow;
    } catch (e, stack) {
      debugPrint('AuthRepository: UNKNOWN ERROR during Google Sign-In: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.verifyOtp(email: email, code: code);
    // Save OTP verification state and auth response
    await _setOtpVerified(true);
    if (response.userStatus?['registration_completed'] == true) {
      await _setRegistrationCompleted(true);
    }
    await _saveAuthResponse(response);
    return response;
  }

  Future<void> resendOtp({required String email}) async {
    await _apiClient.resendOtp(email: email);
  }

  Future<ProfileResponse> completeProfile(ProfileRequest request) async {
    final response = await _apiClient.completeProfile(request);
    // Save profile completion state
    await _setProfileCompleted(true);
    // Save profile data for restaurant setup
    await _saveProfileData(request);
    // Save the new tokens if they are provided
    if (response.access != null && response.refresh != null) {
      await _dioService.setTokens(response.access!, response.refresh!);
    }
    return response;
  }

  Future<void> selectMode(String mode) async {
    final email = await getUserEmail();
    if (email == null) {
      throw Exception('User email not found locally');
    }
    final response = await _apiClient.selectMode(email: email, mode: mode);

    // Save the new tokens if they are provided
    if (response.access != null && response.refresh != null) {
      await _dioService.setTokens(response.access!, response.refresh!);
    }

    final box = await _getAuthStateBox();
    await box.put('selected_mode', mode);
    await _setModeSelected(true);
  }

  Future<void> completeRestaurantSetup() async {
    await _setRegistrationCompleted(true);
  }

  Future<void> signOut() async {
    debugPrint('AuthRepository: Signing out...');

    // Sign out from Google
    await _googleSignIn.signOut();

    // Clear auth state box
    final box = await _getAuthStateBox();
    await box.clear();

    // Clear tokens from DioService
    await _dioService.clearTokens();

    debugPrint(
      'AuthRepository: Signed out successfully - all tokens and auth state cleared',
    );
  }

  // Authentication state management
  Future<void> _saveUserEmail(String email) async {
    final box = await _getAuthStateBox();
    await box.put(keyUserEmail, email);
  }

  Future<void> _setOtpVerified(bool verified) async {
    final box = await _getAuthStateBox();
    await box.put(keyOtpVerified, verified.toString());
  }

  Future<void> _setProfileCompleted(bool completed) async {
    final box = await _getAuthStateBox();
    await box.put(keyProfileCompleted, completed.toString());
  }

  Future<void> _setModeSelected(bool selected) async {
    final box = await _getAuthStateBox();
    await box.put(keyModeSelected, selected.toString());
  }

  Future<void> _setRegistrationCompleted(bool completed) async {
    final box = await _getAuthStateBox();
    await box.put(keyRegistrationCompleted, completed.toString());
  }

  Future<void> _saveAuthResponse(AuthResponse response) async {
    final box = await _getAuthStateBox();
    await box.put(keyAuthResponse, jsonEncode(response.toJson()));
  }

  Future<String?> getUserEmail() async {
    final box = await _getAuthStateBox();
    return box.get(keyUserEmail);
  }

  Future<bool> isOtpVerified() async {
    final box = await _getAuthStateBox();
    final value = box.get(keyOtpVerified);
    return value == 'true';
  }

  Future<bool> isProfileCompleted() async {
    final box = await _getAuthStateBox();
    final value = box.get(keyProfileCompleted);
    return value == 'true';
  }

  Future<bool> isModeSelected() async {
    final box = await _getAuthStateBox();
    final value = box.get(keyModeSelected);
    return value == 'true';
  }

  Future<bool> isRegistrationCompleted() async {
    final box = await _getAuthStateBox();
    final value = box.get(keyRegistrationCompleted);
    return value == 'true';
  }

  Future<AuthResponse?> getSavedAuthResponse() async {
    final box = await _getAuthStateBox();
    final value = box.get(keyAuthResponse);
    if (value != null) {
      try {
        final json = jsonDecode(value);
        return AuthResponse.fromJson(json);
      } catch (e) {
        debugPrint('Error parsing saved auth response: $e');
        return null;
      }
    }
    return null;
  }

  // Save profile data for use in restaurant setup
  Future<void> _saveProfileData(ProfileRequest request) async {
    final box = await _getAuthStateBox();
    final profileData = {
      'restaurantName': request.restaurantName,
      'phone': request.phone,
      'address': request.address,
      'username': request.username,
      'latitude': request.latitude,
      'longitude': request.longitude,
    };
    await box.put(keyProfileData, jsonEncode(profileData));
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

  // Get profile data for restaurant setup
  Future<Map<String, dynamic>?> getProfileData() async {
    final box = await _getAuthStateBox();
    final value = box.get(keyProfileData);
    if (value != null) {
      try {
        return jsonDecode(value) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error parsing saved profile data: $e');
        return null;
      }
    }
    return null;
  }

  Future<String?> getSelectedMode() async {
    final box = await _getAuthStateBox();
    return box.get('selected_mode');
  }

  Future<Map<String, dynamic>> getAdminStatus() async {
    try {
      return await _apiClient.getAdminStatus();
    } catch (e) {
      debugPrint('Error getting admin status: $e');
      return {};
    }
  }

  // Check authentication state on app start
  Future<AuthState> checkAuthState() async {
    final email = await getUserEmail();
    if (email == null) {
      return AuthState.unauthenticated;
    }

    if (!(await isOtpVerified())) {
      return AuthState.needsOtpVerification;
    }

    if (!(await isProfileCompleted())) {
      return AuthState.needsProfileCompletion;
    }

    if (!(await isModeSelected())) {
      return AuthState.needsModeSelection;
    }

    if (await isRegistrationCompleted()) {
      return AuthState.authenticated;
    }

    // Check if mode is online and restaurant is not created
    final mode = await getSelectedMode();
    if (mode == 'online') {
      try {
        final status = await getAdminStatus();
        final isAdmin = status['is_admin'] ?? false;

        if (!isAdmin) {
          debugPrint('AuthRepository: User is not an admin, signing out');
          await signOut();
          return AuthState.unauthenticated;
        }

        if (status['registration_completed'] == true) {
          await _setRegistrationCompleted(true);
          return AuthState.authenticated;
        }
        final restaurantCreated = status['restaurant_created'] ?? false;
        if (!restaurantCreated) {
          return AuthState.needsRestaurantSetup;
        }
      } catch (e) {
        debugPrint('Error checking admin status: $e');
        // If error, assume needs setup
        return AuthState.needsRestaurantSetup;
      }
    }

    return AuthState.authenticated;
  }
}

enum AuthState {
  unauthenticated,
  needsOtpVerification,
  needsProfileCompletion,
  needsModeSelection,
  needsRestaurantSetup,
  authenticated,
}
