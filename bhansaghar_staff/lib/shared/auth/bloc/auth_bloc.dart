import 'package:bhansaghar_staff/core/models/auth_models.dart';
import 'package:bhansaghar_staff/core/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthClaimInviteWithQR>(_onAuthClaimInviteWithQR);
    on<AuthGoogleLoginFromQR>(_onAuthGoogleLoginFromQR);
    on<AuthGoogleLoginFromQRWithAccount>(_onAuthGoogleLoginFromQRWithAccount);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthVerifyOtpRequested>(_onAuthVerifyOtpRequested);
    on<AuthRoleSelected>(_onAuthRoleSelected);
  }

  /// Getter to expose authRepository for UI widgets
  AuthRepository get authRepository => _authRepository;
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      // Check if user is already authenticated
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final response = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      await _authRepository.setTokens(
        response.accessToken,
        response.refreshToken,
      );
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final response = await _authRepository.googleLogin();
      await _authRepository.setTokens(
        response.accessToken,
        response.refreshToken,
      );
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      debugPrint('❌ AuthGoogleLoginRequested error: $e');
      final errorMessage = _parseErrorMessage(e.toString());
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onAuthClaimInviteWithQR(
    AuthClaimInviteWithQR event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final response = await _authRepository.claimInviteWithQR(
        inviteId: event.inviteId,
      );
      await _authRepository.setTokens(
        response.accessToken,
        response.refreshToken,
      );
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      debugPrint('❌ AuthClaimInviteWithQR error: $e');
      final errorMessage = _parseErrorMessage(e.toString());
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onAuthGoogleLoginFromQR(
    AuthGoogleLoginFromQR event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
      '🎯 AuthGoogleLoginFromQR event received with inviteId: ${event.inviteId}',
    );
    try {
      emit(const AuthLoading());
      debugPrint('⏳ Emitted AuthLoading state');
      final response = await _authRepository.googleLoginFromQR(
        inviteId: event.inviteId,
      );
      debugPrint('✅ googleLoginFromQR completed successfully');
      await _authRepository.setTokens(
        response.accessToken,
        response.refreshToken,
      );
      emit(AuthAuthenticated(response.user));
      debugPrint('🎉 Emitted AuthAuthenticated state');
    } catch (e) {
      debugPrint('❌ AuthGoogleLoginFromQR error: $e');
      final errorMessage = _parseErrorMessage(e.toString());
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onAuthGoogleLoginFromQRWithAccount(
    AuthGoogleLoginFromQRWithAccount event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
      '🎯 AuthGoogleLoginFromQRWithAccount event received with inviteId: ${event.inviteId}',
    );
    try {
      emit(const AuthLoading());
      debugPrint('⏳ Emitted AuthLoading state');

      // Cast to GoogleSignInAccount
      final selectedAccount = event.selectedAccount as GoogleSignInAccount;
      debugPrint('📱 Using selected account: ${selectedAccount.email}');

      final response = await _authRepository.claimInviteWithQR(
        inviteId: event.inviteId,
        selectedAccount: selectedAccount,
      );
      debugPrint('✅ claimInviteWithQR completed successfully');
      await _authRepository.setTokens(
        response.accessToken,
        response.refreshToken,
      );
      emit(AuthAuthenticated(response.user));
      debugPrint('🎉 Emitted AuthAuthenticated state');
    } catch (e) {
      debugPrint('❌ AuthGoogleLoginFromQRWithAccount error: $e');

      // Parse and format error message
      final errorMessage = _parseErrorMessage(e.toString());
      emit(AuthError(errorMessage));
    }
  }

  /// Parse error messages from API responses and exceptions
  String _parseErrorMessage(String error) {
    debugPrint('🔍 Parsing error message: $error');

    // Handle DioException with status codes
    if (error.contains('status code of')) {
      // Try to extract the JSON response body
      if (error.contains('{') && error.contains('}')) {
        try {
          final match = RegExp(r'\{[^{}]*"error"[^{}]*\}').firstMatch(error);
          if (match != null) {
            final jsonStr = match.group(0);
            debugPrint('📋 Found JSON response: $jsonStr');

            // Extract error field
            final errorFieldMatch = RegExp(
              r'"error"\s*:\s*"([^"]*)"',
            ).firstMatch(jsonStr!);
            if (errorFieldMatch != null) {
              final errorMsg = errorFieldMatch.group(1);
              debugPrint('✅ Extracted error message: $errorMsg');
              return errorMsg ?? 'An error occurred. Please try again.';
            }
          }
        } catch (e) {
          debugPrint('Error parsing JSON response: $e');
        }
      }

      // Status code based error messages
      if (error.contains('status code of 403')) {
        if (error.contains('This login is only for staff members')) {
          return 'You signed in with the wrong account. This login is only for staff members (kitchen/waiter). Please select the correct email.';
        }
        return 'Access denied. Make sure you\'re signed in with the correct email.';
      }
      if (error.contains('status code of 400')) {
        return 'Invalid invitation or account mismatch. Please try again with the correct email.';
      }
      if (error.contains('status code of 404')) {
        return 'This invitation was not found or has already been claimed.';
      }
    }

    // Handle specific error messages
    if (error.contains('This invitation is for')) {
      return 'This invitation is for a different email address. Please sign in with the correct account.';
    }
    if (error.contains('expired')) {
      return 'This invitation has expired. Please ask the restaurant owner for a new invitation.';
    }
    if (error.contains('cancelled')) {
      return 'Sign in was cancelled.';
    }
    if (error.contains('Google sign in cancelled')) {
      return 'Sign in was cancelled.';
    }

    // Truncate very long errors
    return error.length > 150 ? '${error.substring(0, 150)}...' : error;
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final response = await _authRepository.register(
        email: event.email,
        password: event.password,
        name: event.name,
        role: event.role,
      );
      await _authRepository.setTokens(
        response.accessToken,
        response.refreshToken,
      );
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final response = await _authRepository.verifyOtp(
        email: event.email,
        otp: event.otp,
      );
      await _authRepository.setTokens(
        response.accessToken,
        response.refreshToken,
      );
      emit(AuthAuthenticated(response.user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthRoleSelected(
    AuthRoleSelected event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.saveUserRole(event.role);
      emit(const AuthRoleSelection());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    try {
      if (json['user'] != null) {
        final user = User(
          id: json['user']['id'] ?? '',
          email: json['user']['email'] ?? '',
          name: json['user']['name'] ?? '',
          role: UserRole.values.firstWhere(
            (role) => role.toString().split('.').last == json['user']['role'],
            orElse: () => UserRole.unknown,
          ),
          isVerified: json['user']['isVerified'] ?? false,
          profileCompleted: json['user']['profileCompleted'] ?? false,
        );
        return AuthAuthenticated(user);
      }
    } catch (_) {}
    return const AuthUnauthenticated();
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    if (state is AuthAuthenticated) {
      return {
        'user': {
          'id': state.user.id,
          'email': state.user.email,
          'name': state.user.name,
          'role': state.user.role.toString().split('.').last,
          'isVerified': state.user.isVerified,
          'profileCompleted': state.user.profileCompleted,
        },
      };
    }
    return null;
  }
}
