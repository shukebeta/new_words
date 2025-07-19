import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';
  static const String _autoDetectModeKey = 'auto_detect_mode';

  Locale _locale = const Locale('en', ''); // Default to English
  bool _isInitialized = false;
  bool _isAutoDetectMode = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;
  bool get isAutoDetectMode => _isAutoDetectMode;

  // Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('zh', ''), // Chinese
  ];

  /// Safe initialization that won't crash the app
  Future<void> initializeLocale() async {
    if (_isInitialized) return;

    try {
      debugPrint('Initializing locale provider...');

      // First try to load saved locale
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      final savedAutoDetectMode = prefs.getBool(_autoDetectModeKey) ?? false;
      
      debugPrint('DEBUG: Saved locale code: $savedLocaleCode');
      debugPrint('DEBUG: Saved auto-detect mode: $savedAutoDetectMode');

      if (savedLocaleCode != null &&
          _isSupportedLocale(Locale(savedLocaleCode, '')) &&
          !savedAutoDetectMode) {
        debugPrint('Found saved manual locale: $savedLocaleCode');
        _locale = Locale(savedLocaleCode, '');
        _isAutoDetectMode = false;
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // Try to detect system locale safely
      debugPrint('DEBUG: No saved manual locale found, detecting system locale...');
      _isAutoDetectMode = true;
      await _detectSystemLocaleSafely();
    } catch (e) {
      debugPrint('Error initializing locale: $e');
      // Fallback to English
      _locale = const Locale('en', '');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Safe system locale detection
  Future<void> _detectSystemLocaleSafely() async {
    try {
      // Use a post-frame callback to ensure Flutter is ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if we have access to platform dispatcher
      final platformDispatcher = WidgetsBinding.instance.platformDispatcher;
      debugPrint('DEBUG: Platform dispatcher locales count: ${platformDispatcher.locales.length}');
      
      if (platformDispatcher.locales.isNotEmpty) {
        final systemLocale = platformDispatcher.locales.first;
        debugPrint('DEBUG: System locale detected: ${systemLocale.toString()}');
        debugPrint('DEBUG: System locale language code: ${systemLocale.languageCode}');
        debugPrint('DEBUG: System locale country code: ${systemLocale.countryCode}');
        debugPrint('DEBUG: All system locales: ${platformDispatcher.locales.map((l) => l.toString()).join(", ")}');

        // Try to match with supported locales
        final matchedLocale = _findSupportedLocale(systemLocale);
        debugPrint('DEBUG: Matched locale: ${matchedLocale?.toString() ?? 'null'}');
        
        if (matchedLocale != null) {
          _locale = matchedLocale;
          debugPrint('DEBUG: Using system locale: ${_locale.languageCode}');
          return;
        } else {
          debugPrint('DEBUG: System locale ${systemLocale.languageCode} not supported, checking supported locales...');
          debugPrint('DEBUG: Supported locales: ${supportedLocales.map((l) => l.languageCode).join(", ")}');
        }
      } else {
        debugPrint('DEBUG: No system locales available from platform dispatcher');
      }

      debugPrint('DEBUG: No matching system locale found, falling back to English');
      _locale = const Locale('en', '');
    } catch (e) {
      debugPrint('DEBUG: Error detecting system locale: $e');
      _locale = const Locale('en', '');
    }
  }

  /// Change locale and save to SharedPreferences
  Future<void> changeLocale(Locale newLocale) async {
    if (!_isSupportedLocale(newLocale)) {
      debugPrint('Locale ${newLocale.languageCode} not supported');
      return;
    }

    _locale = newLocale;
    _isAutoDetectMode = false; // Manual selection disables auto-detect
    notifyListeners();

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
      await prefs.setBool(_autoDetectModeKey, false);
      debugPrint('DEBUG: Locale manually changed to: ${newLocale.languageCode}');
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Check if a locale is supported
  bool _isSupportedLocale(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  /// Find a supported locale that matches the given locale
  Locale? _findSupportedLocale(Locale locale) {
    // First try exact match
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    // Extract base language code (handle zh-CN -> zh)
    final baseLanguageCode = locale.languageCode.split('-')[0].split('_')[0];

    // Try to match base language code
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == baseLanguageCode) {
        return supportedLocale;
      }
    }

    return null;
  }

  /// Get current locale language code
  String get currentLanguageCode => _locale.languageCode;

  /// Check if current locale is English
  bool get isEnglish => _locale.languageCode == 'en';

  /// Check if current locale is Chinese
  bool get isChinese => _locale.languageCode == 'zh';

  /// Reset to auto-detect mode and re-detect system locale
  Future<void> resetToAutoDetect() async {
    try {
      debugPrint('DEBUG: Resetting to auto-detect mode...');
      
      // Clear saved preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
      await prefs.setBool(_autoDetectModeKey, true);
      
      // Reset state and re-detect
      _isAutoDetectMode = true;
      await _detectSystemLocaleSafely();
      
      debugPrint('DEBUG: Reset complete, current locale: ${_locale.languageCode}, auto-detect: $_isAutoDetectMode');
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting to auto-detect: $e');
    }
  }

  /// Clear saved locale preference (for testing)
  Future<void> clearSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
      await prefs.remove(_autoDetectModeKey);
      debugPrint('Saved locale preference cleared');
    } catch (e) {
      debugPrint('Error clearing saved locale: $e');
    }
  }

  /// Enable auto-detect mode
  Future<void> enableAutoDetect() async {
    try {
      debugPrint('DEBUG: Enabling auto-detect mode...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_autoDetectModeKey, true);
      await prefs.remove(_localeKey); // Remove manual selection
      
      _isAutoDetectMode = true;
      await _detectSystemLocaleSafely();
      
      debugPrint('DEBUG: Auto-detect enabled, current locale: ${_locale.languageCode}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error enabling auto-detect: $e');
    }
  }
}
