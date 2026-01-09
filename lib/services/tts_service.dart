import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:new_words/utils/app_logger_interface.dart';

/// Text-to-Speech service for word and sample sentence pronunciation
///
/// Supports Android, iOS, macOS, Web, Windows (not Linux)
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final AppLoggerInterface _logger;

  String? _currentLocale;
  bool _isInitialized = false;

  // Language code mapping from ISO 639-1 to TTS locales
  static const Map<String, String> _localeMap = {
    'en': 'en-US',
    'zh': 'zh-CN',
    'es': 'es-ES',
    'fr': 'fr-FR',
    'de': 'de-DE',
    'ja': 'ja-JP',
    'ko': 'ko-KR',
    'it': 'it-IT',
    'pt': 'pt-BR',
    'ru': 'ru-RU',
    'ar': 'ar-SA',
    'hi': 'hi-IN',
    'th': 'th-TH',
    'vi': 'vi-VN',
    'id': 'id-ID',
    'ms': 'ms-MY',
    'tr': 'tr-TR',
    'pl': 'pl-PL',
    'nl': 'nl-NL',
    'sv': 'sv-SE',
    'no': 'nb-NO',
    'da': 'da-DK',
    'fi': 'fi-FI',
  };

  TtsService({AppLoggerInterface? logger})
      : _logger = logger ?? const _DefaultLogger();

  /// Initialize TTS with optional language
  Future<void> init({String? language}) async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setSharedInstance(true);
      await _setLanguage(language ?? 'en');
      _isInitialized = true;
      _logger.i('TTS initialized with language: $_currentLocale');
    } catch (e) {
      _logger.e('Failed to initialize TTS: $e');
      rethrow;
    }
  }

  /// Speak text with specified language
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      await init(language: language);
    }

    if (text.isEmpty) {
      _logger.d('Attempted to speak empty text');
      return;
    }

    try {
      // Stop any ongoing speech
      await _flutterTts.stop();

      // Set language if different from current
      if (language != null && _currentLocale != _localeMap[language]) {
        await _setLanguage(language);
      }

      await _flutterTts.speak(text);
      _logger.i('Speaking: "${text.length > 50 ? text.substring(0, 50) : text}"');
    } catch (e) {
      _logger.e('Failed to speak: $e');
    }
  }

  /// Stop current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      _logger.e('Failed to stop TTS: $e');
    }
  }

  /// Set TTS language
  Future<void> _setLanguage(String languageCode) async {
    final locale = _localeMap[languageCode] ?? 'en-US';
    await _flutterTts.setLanguage(locale);
    _currentLocale = locale;
  }

  bool get isSupported {
    try {
      return !Platform.isLinux;
    } on UnsupportedError {
      return false;
    }
    return false;
  }

  /// Get available languages for TTS
  Future<List<String>> getLanguages() async {
    try {
      return await _flutterTts.getLanguages ?? [];
    } catch (e) {
      _logger.e('Failed to get languages: $e');
      return [];
    }
  }

  void dispose() {
    _flutterTts.stop();
  }
}

/// Default logger for when no logger is injected
class _DefaultLogger implements AppLoggerInterface {
  const _DefaultLogger();

  @override
  void i(String message) {
    // Silent in production
  }

  @override
  void d(String message) {
    // Silent in production
  }

  @override
  void e(String message) {
    // Silent in production
  }

  @override
  Future<void> initialize() async {
    // No-op for default logger
  }
}
