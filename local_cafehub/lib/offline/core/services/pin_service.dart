import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PinService {
  final Box _box;
  static const _pinKey = 'user_pin_hash';
  static const _saltKey = 'user_pin_salt';

  PinService(this._box);

  /// Generates a random salt
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(saltBytes);
  }

  /// Hashes the PIN with the given salt
  String _hashPin(String pin, String salt) {
    final key = utf8.encode(pin + salt);
    final bytes = sha256.convert(key).bytes;
    return base64Url.encode(bytes);
  }

  /// Sets a new PIN
  Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);

    await _box.put(_saltKey, salt);
    await _box.put(_pinKey, hash);
  }

  /// Verifies the entered PIN
  Future<bool> verifyPin(String pin) async {
    final salt = _box.get(_saltKey) as String?;
    final storedHash = _box.get(_pinKey) as String?;

    if (salt == null || storedHash == null) {
      return false;
    }

    final hash = _hashPin(pin, salt);
    return hash == storedHash;
  }

  /// Checks if a PIN is set
  bool isPinSet() {
    final hash = _box.get(_pinKey);
    return hash != null;
  }

  /// Deletes the PIN (Turn off PIN)
  Future<void> deletePin() async {
    await _box.delete(_pinKey);
    await _box.delete(_saltKey);
  }
}
