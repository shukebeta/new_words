import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('en', ''); // Default to English
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

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

      if (savedLocaleCode != null &&
          _isSupportedLocale(Locale(savedLocaleCode, ''))) {
        debugPrint('Found saved locale: $savedLocaleCode');
        _locale = Locale(savedLocaleCode, '');
        _isInitialized = true;
        notifyListeners();
        return;
      }

      // Try to detect system locale safely
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
      if (platformDispatcher.locales.isNotEmpty) {
        final systemLocale = platformDispatcher.locales.first;
        debugPrint('System locale detected: ${systemLocale.languageCode}');

        // Try to match with supported locales
        final matchedLocale = _findSupportedLocale(systemLocale);
        if (matchedLocale != null) {
          _locale = matchedLocale;
          debugPrint('Using system locale: ${_locale.languageCode}');
          return;
        }
      }

      debugPrint('No matching system locale found, using English');
      _locale = const Locale('en', '');
    } catch (e) {
      debugPrint('Error detecting system locale: $e');
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
    notifyListeners();

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
      debugPrint('Locale changed to: ${newLocale.languageCode}');
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

  /// Clear saved locale preference (for testing)
  Future<void> clearSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localeKey);
      debugPrint('Saved locale preference cleared');
    } catch (e) {
      debugPrint('Error clearing saved locale: $e');
    }
  }
}
