import 'package:hive_flutter/hive_flutter.dart';

class PreferencesService {
  static const String _boxName = 'preferences';
  static const String _keyTtsEnabled = 'tts_enabled';
  static const String _keyTtsVolume = 'tts_volume';
  static const String _keyTtsRate = 'tts_rate';
  static const String _keyTtsPitch = 'tts_pitch';
  static const String _keyLanguageCode = 'language_code';

  late Box _box;

  Future<void> initialize() async {
    _box = await Hive.openBox(_boxName);
  }

  bool get ttsEnabled => _box.get(_keyTtsEnabled, defaultValue: true);
  double get ttsVolume => _box.get(_keyTtsVolume, defaultValue: 1.0);
  double get ttsRate => _box.get(_keyTtsRate, defaultValue: 0.5);
  double get ttsPitch => _box.get(_keyTtsPitch, defaultValue: 1.0);
  String get languageCode => _box.get(_keyLanguageCode, defaultValue: 'en');

  Future<void> setTtsEnabled(bool value) async {
    await _box.put(_keyTtsEnabled, value);
  }

  Future<void> setTtsVolume(double value) async {
    await _box.put(_keyTtsVolume, value);
  }

  Future<void> setTtsRate(double value) async {
    await _box.put(_keyTtsRate, value);
  }

  Future<void> setTtsPitch(double value) async {
    await _box.put(_keyTtsPitch, value);
  }

  Future<void> setLanguageCode(String value) async {
    await _box.put(_keyLanguageCode, value);
  }
}
