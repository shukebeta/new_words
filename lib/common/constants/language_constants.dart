import 'package:new_words/entities/language.dart';

class LanguageConstants {
  // Supported languages list - used as fallback when API fails
  static const List<Language> supportedLanguages = [
    Language(code: 'en', name: 'English'),
    Language(code: 'es', name: 'Spanish'),
    Language(code: 'fr', name: 'French'),
    Language(code: 'de', name: 'German'),
    Language(code: 'it', name: 'Italian'),
    Language(code: 'pt', name: 'Portuguese'),
    Language(code: 'zh-CN', name: 'Chinese (Simplified)'),
    Language(code: 'zh-TW', name: 'Chinese (Traditional)'),
    Language(code: 'ja', name: 'Japanese'),
    Language(code: 'ko', name: 'Korean'),
    Language(code: 'ru', name: 'Russian'),
  ];
}