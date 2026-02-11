import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final Box _box;
  final LocalAuthentication _localAuth = LocalAuthentication();
  static const _biometricEnabledKey = 'biometric_enabled';

  BiometricService(this._box);

  /// Check if device can check biometrics
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  /// Check if device is capable (has hardware + enrolled biometrics)
  Future<bool> isDeviceSupported() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        return false;
      }

      // Also check if there are any enrolled biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticate() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return false;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
      );

      return authenticated;
    } catch (e) {
      return false;
    }
  }

  /// Check if biometric is enabled by user
  bool isBiometricEnabled() {
    return _box.get(_biometricEnabledKey, defaultValue: false) as bool;
  }

  /// Enable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _box.put(_biometricEnabledKey, enabled);
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    await _box.put(_biometricEnabledKey, false);
  }
}
