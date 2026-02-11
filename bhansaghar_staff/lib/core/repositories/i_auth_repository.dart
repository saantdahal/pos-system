import 'package:bhansaghar_staff/core/models/auth_models.dart';

abstract class IAuthRepository {
  Future<void> setTokens(String access, String refresh);
  Future<AuthResponse> login({required String email, required String password});
  Future<AuthResponse> googleLogin();
  Future<AuthResponse> claimInviteWithQR({required String inviteId});
  Future<AuthResponse> googleLoginFromQR({required String inviteId});
  Future<String?> getInvitationEmail({required String inviteId});
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });
  Future<AuthResponse> verifyOtp({required String email, required String otp});
  Future<void> logout();
  Future<String?> getRefreshToken();
  Future<void> saveUserRole(UserRole role);
  Future<User?> getCurrentUser();
}
