import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/services/pin_service.dart';
import 'package:bhansa_ghar/offline/core/services/biometric_service.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final PinService _pinService;
  final BiometricService _biometricService;

  AuthBloc({
    required PinService pinService,
    required BiometricService biometricService,
  }) : _pinService = pinService,
       _biometricService = biometricService,
       super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthPinSet>(_onAuthPinSet);
    on<AuthPinVerified>(_onAuthPinVerified);
    on<AuthPinDisabled>(_onAuthPinDisabled);
    on<AuthBiometricRequested>(_onAuthBiometricRequested);
    on<AuthBiometricEnabled>(_onAuthBiometricEnabled);
    on<AuthBiometricDisabled>(_onAuthBiometricDisabled);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isPinSet = _pinService.isPinSet();
      if (isPinSet) {
        // Check if biometric is enabled
        final isBiometricEnabled = _biometricService.isBiometricEnabled();
        if (isBiometricEnabled) {
          emit(AuthBiometricRequired());
        } else {
          emit(AuthPinLocked());
        }
      } else {
        emit(AuthPinSetupRequired());
      }
    } catch (e) {
      emit(
        AuthFailure(
          'Failed to check authentication status: $e',
          isPinSet: _pinService.isPinSet(),
        ),
      );
    }
  }

  Future<void> _onAuthPinSet(AuthPinSet event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _pinService.setPin(event.pin);
      emit(AuthPinSetSuccess());
    } catch (e) {
      emit(
        AuthFailure('Failed to set PIN: $e', isPinSet: _pinService.isPinSet()),
      );
    }
  }

  Future<void> _onAuthPinVerified(
    AuthPinVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isValid = await _pinService.verifyPin(event.pin);
      if (isValid) {
        emit(AuthPinVerifiedSuccess());
      } else {
        emit(AuthFailure('Incorrect PIN', isPinSet: _pinService.isPinSet()));
      }
    } catch (e) {
      emit(
        AuthFailure(
          'Failed to verify PIN: $e',
          isPinSet: _pinService.isPinSet(),
        ),
      );
    }
  }

  Future<void> _onAuthPinDisabled(
    AuthPinDisabled event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _pinService.deletePin();
      // Also disable biometric when PIN is disabled
      await _biometricService.disableBiometric();
      emit(AuthPinSetupRequired());
    } catch (e) {
      emit(
        AuthFailure(
          'Failed to disable PIN: $e',
          isPinSet: _pinService.isPinSet(),
        ),
      );
    }
  }

  Future<void> _onAuthBiometricRequested(
    AuthBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _biometricService.authenticate();
      if (isAuthenticated) {
        emit(AuthPinVerifiedSuccess());
      } else {
        emit(
          AuthFailure(
            'Biometric authentication failed',
            isPinSet: _pinService.isPinSet(),
          ),
        );
      }
    } catch (e) {
      emit(
        AuthFailure(
          'Biometric authentication error: $e',
          isPinSet: _pinService.isPinSet(),
        ),
      );
    }
  }

  Future<void> _onAuthBiometricEnabled(
    AuthBiometricEnabled event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _biometricService.setBiometricEnabled(event.enabled);
      // Re-check auth status to update state
      add(AuthCheckRequested());
    } catch (e) {
      emit(
        AuthFailure(
          'Failed to update biometric setting: $e',
          isPinSet: _pinService.isPinSet(),
        ),
      );
    }
  }

  Future<void> _onAuthBiometricDisabled(
    AuthBiometricDisabled event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _biometricService.disableBiometric();
      // Re-check auth status to update state
      add(AuthCheckRequested());
    } catch (e) {
      emit(
        AuthFailure(
          'Failed to disable biometric: $e',
          isPinSet: _pinService.isPinSet(),
        ),
      );
    }
  }
}
