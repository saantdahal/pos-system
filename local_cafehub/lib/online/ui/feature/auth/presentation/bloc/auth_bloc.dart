import 'package:bhansa_ghar/online/core/models/auth/auth_response.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_request.dart';
import 'package:bhansa_ghar/online/core/models/restaurant/restaurant_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/core/repositories/auth_repository.dart';
import 'package:bhansa_ghar/online/core/services/user_friendly_response_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class OnlineAuthBloc extends Bloc<OnlineAuthEvent, OnlineAuthState> {
  final AuthRepository _authRepository;

  AuthRepository get authRepository => _authRepository;

  OnlineAuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<GoogleLoginRequested>(_onGoogleLoginRequested);
    on<OtpVerificationRequested>(_onOtpVerificationRequested);
    on<ResendOtpRequested>(_onResendOtpRequested);
    on<ProfileCompletionRequested>(_onProfileCompletionRequested);
    on<ModeSelectionRequested>(_onModeSelectionRequested);
    on<RestaurantSetupCompleted>(_onRestaurantSetupCompleted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<OnlineAuthState> emit,
  ) async {
    debugPrint('AuthBloc: _onAuthStarted called');
    try {
      final authState = await _authRepository.checkAuthState();
      debugPrint('AuthBloc: checkAuthState returned: $authState');

      switch (authState) {
        case AuthState.unauthenticated:
          debugPrint('AuthBloc: Emitting Unauthenticated');
          emit(Unauthenticated());
          break;
        case AuthState.needsOtpVerification:
          final email = await _authRepository.getUserEmail();
          debugPrint(
            'AuthBloc: Emitting NeedsOtpVerification for email: $email',
          );
          if (email != null) {
            emit(NeedsOtpVerification(email));
          } else {
            emit(Unauthenticated());
          }
          break;
        case AuthState.needsProfileCompletion:
          final authResponse = await _authRepository.getSavedAuthResponse();
          final email = await _authRepository.getUserEmail();
          debugPrint('AuthBloc: Emitting NeedsProfileCompletion');
          if (authResponse != null && email != null) {
            emit(NeedsProfileCompletion(authResponse, email));
          } else {
            emit(Unauthenticated());
          }
          break;
        case AuthState.needsModeSelection:
          final authResponse = await _authRepository.getSavedAuthResponse();
          debugPrint('AuthBloc: Emitting NeedsModeSelection');
          if (authResponse != null) {
            emit(NeedsModeSelection(authResponse));
          } else {
            emit(Unauthenticated());
          }
          break;
        case AuthState.needsRestaurantSetup:
          final authResponse = await _authRepository.getSavedAuthResponse();
          final profileData = await _authRepository.getProfileData();
          debugPrint('AuthBloc: Emitting NeedsRestaurantSetup');
          if (authResponse != null) {
            emit(NeedsRestaurantSetup(authResponse, profileData));
          } else {
            emit(Unauthenticated());
          }
          break;
        case AuthState.authenticated:
          final authResponse = await _authRepository.getSavedAuthResponse();
          debugPrint('AuthBloc: Emitting Authenticated');
          if (authResponse != null) {
            emit(Authenticated(authResponse));
          } else {
            emit(Unauthenticated());
          }
          break;
      }
    } catch (e) {
      debugPrint('AuthBloc: Error checking auth state: $e');
      emit(Unauthenticated());
    }
  }

  Future<void> _onGoogleLoginRequested(
    GoogleLoginRequested event,
    Emitter<OnlineAuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.signInWithGoogle();

      // Check if verification is needed
      if (response.verificationSent) {
        emit(
          NeedsOtpVerification(
            response.email,
            verificationCode: response.verificationCode,
          ),
        );
      } else {
        // Verification not sent means email is verified (or already verified)
        // Check user status for next steps
        final userStatus = response.userStatus;
        if (userStatus != null) {
          final isProfileCompleted = userStatus['profile_completed'] ?? false;
          final isModeSelected =
              userStatus['mode_selection_completed'] ?? false;
          final isRegistrationCompleted =
              userStatus['registration_completed'] ?? false;
          // Make sure backend sends this or we infer it

          // Create an AuthResponse to pass to states
          // We might need to construct it from GoogleAuthResponse if possible,
          // or just pass necessary data.
          // Existing states expect AuthResponse which has access/refresh.
          // GoogleAuthResponse now has them.

          final authResponse = AuthResponse(
            access: response.access ?? '',
            refresh: response.refresh ?? '',
            userStatus: userStatus,
            // Map other fields if needed, but AuthResponse structure might differ slightly
            // Let's check AuthResponse definition.
            // It seems AuthResponse matches what we need mostly.
          );

          final isAdmin = userStatus['is_admin'] ?? false;

          if (!isAdmin && isRegistrationCompleted) {
            // If registration is complete but not an admin, block access
            await _authRepository.signOut();
            emit(
              const AuthFailure('Access denied. This app is for admins only.'),
            );
            return;
          }

          if (isRegistrationCompleted) {
            emit(Authenticated(authResponse));
          } else if (!isProfileCompleted) {
            emit(NeedsProfileCompletion(authResponse, response.email));
          } else if (!isModeSelected) {
            emit(NeedsModeSelection(authResponse));
          } else {
            // Registration not complete, but properties complete and mode selected.
            // This implies we are in the middle of a multi-step process that isn't fully "registered" yet.
            // Specifically, for "Online" mode, this means Restaurant Setup is needed.
            // For "Offline", registration_completed should be true if mode is selected (handled by backend).

            // So if we are here, it MUST be Online mode waiting for Restaurant Setup.

            // Fetch profile data to prepopulate restaurant setup
            try {
              final profileData = await _authRepository.getProfileData();
              emit(NeedsRestaurantSetup(authResponse, profileData));
            } catch (e) {
              // If profile fetch fails, we can still proceed but without prepopulation
              emit(NeedsRestaurantSetup(authResponse, null));
            }
          }
        } else {
          // Fallback if no status
          emit(
            Authenticated(
              AuthResponse(
                access: response.access ?? '',
                refresh: response.refresh ?? '',
              ),
            ),
          );
        }
      }
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onOtpVerificationRequested(
    OtpVerificationRequested event,
    Emitter<OnlineAuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await _authRepository.verifyOtp(
        email: event.email,
        code: event.code,
      );
      // After OTP verification, user needs to complete profile
      emit(NeedsProfileCompletion(response, event.email));
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onResendOtpRequested(
    ResendOtpRequested event,
    Emitter<OnlineAuthState> emit,
  ) async {
    try {
      await _authRepository.resendOtp(email: event.email);
      emit(OtpResent()); // Assuming we add this state
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onProfileCompletionRequested(
    ProfileCompletionRequested event,
    Emitter<OnlineAuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NeedsProfileCompletion) return;

    emit(AuthLoading());
    try {
      String email = event.request.email;
      if (email.isEmpty) {
        email = currentState.email;
      }

      final request = ProfileRequest(
        email: email,
        username: event.request.username,
        phone: event.request.phone,
        address: event.request.address,
        latitude: event.request.latitude,
        longitude: event.request.longitude,
        restaurantName: event.request.restaurantName,
      );

      final response = await _authRepository.completeProfile(request);
      // Tokens are saved in repository
      // Create updated auth response with tokens
      final updatedAuthResponse = AuthResponse(
        access: response.access,
        refresh: response.refresh,
        userStatus: {
          'is_google_verified': response.user?['is_google_verified'] ?? false,
          'is_email_verified': response.user?['is_email_verified'] ?? false,
          'profile_completed': response.user?['profile_completed'] ?? false,
        },
      );
      // After profile completion, user needs to select mode
      emit(NeedsModeSelection(updatedAuthResponse));
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onModeSelectionRequested(
    ModeSelectionRequested event,
    Emitter<OnlineAuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NeedsModeSelection) return;

    emit(AuthLoading());
    try {
      await _authRepository.selectMode(event.mode);
      // After mode selection, if online mode, need restaurant setup
      if (event.mode == 'online') {
        final profileData = await _authRepository.getProfileData();
        emit(NeedsRestaurantSetup(currentState.authResponse, profileData));
      } else {
        emit(Authenticated(currentState.authResponse));
      }
    } catch (e) {
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onRestaurantSetupCompleted(
    RestaurantSetupCompleted event,
    Emitter<OnlineAuthState> emit,
  ) async {
    final response = event.response as RestaurantResponse;
    if (response.access != null && response.refresh != null) {
      await _authRepository.setTokens(response.access!, response.refresh!);
    }
    await _authRepository.completeRestaurantSetup();
    final currentState = state;
    if (currentState is NeedsRestaurantSetup) {
      emit(Authenticated(currentState.authResponse));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<OnlineAuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(Unauthenticated());
  }
}
