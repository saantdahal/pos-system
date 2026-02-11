import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:bhansa_ghar/offline/core/services/preferences_service.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  late FlutterTts _flutterTts;
  late PreferencesService _preferencesService;

  bool get isEnabled => _preferencesService.ttsEnabled;
  double get volume => _preferencesService.ttsVolume;
  double get rate => _preferencesService.ttsRate;
  double get pitch => _preferencesService.ttsPitch;

  Future<void> initialize(PreferencesService preferencesService) async {
    _preferencesService = preferencesService;
    _flutterTts = FlutterTts();

    if (kIsWeb) {
      // Web specific setup if needed
    } else {
      // Mobile specific setup
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _flutterTts
            .setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            ]);
      }
    }

    await _updateTtsSettings();

    _flutterTts.setStartHandler(() {
      debugPrint("TTS Playing");
    });

    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS Complete");
      _isSpeaking = false;
      _processQueue();
    });

    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
    });
  }

  Future<void> _updateTtsSettings() async {
    await _flutterTts.setVolume(volume);
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
  }

  final List<String> _speakQueue = [];
  bool _isSpeaking = false;

  Future<void> speak(String text) async {
    if (!isEnabled) return;
    if (text.isEmpty) return;

    _speakQueue.add(text);
    if (!_isSpeaking) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    if (_speakQueue.isEmpty) {
      _isSpeaking = false;
      return;
    }

    _isSpeaking = true;
    final text = _speakQueue.removeAt(0);

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error speaking: $e");
      // If error, move to next
      _isSpeaking = false;
      _processQueue();
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint("Error stopping TTS: $e");
    }
  }

  Future<void> setLanguage(String languageCode) async {
    // Map simplified language codes to locale IDs if necessary
    // For now, passing 'en' or 'ne' directly might work or need mapping
    // simple mapping:
    String locale = languageCode;
    if (languageCode == 'en') locale = 'en-US';
    if (languageCode == 'ne') locale = 'ne-NP';

    try {
      final isLanguageAvailable = await _flutterTts.isLanguageAvailable(locale);
      if (isLanguageAvailable) {
        await _flutterTts.setLanguage(locale);
      } else {
        debugPrint("TTS Language not available: $locale");
        // Fallback to English if not available
        await _flutterTts.setLanguage('en-US');
      }
    } catch (e) {
      debugPrint("Error setting language: $e");
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await _preferencesService.setTtsEnabled(enabled);
  }

  Future<void> setVolume(double volume) async {
    await _preferencesService.setTtsVolume(volume);
    await _flutterTts.setVolume(volume);
  }

  Future<void> setRate(double rate) async {
    await _preferencesService.setTtsRate(rate);
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _preferencesService.setTtsPitch(pitch);
    await _flutterTts.setPitch(pitch);
  }
}
