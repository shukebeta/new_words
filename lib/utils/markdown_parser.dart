import 'dart:core';

class MarkdownParser {
  static bool isLanguageText(String text, String languageCode) {
    final totalChars = text.replaceAll(RegExp(r'\s'), '').length;
    if (totalChars < 10) return false;

    final langPrefix = languageCode.toLowerCase().substring(0, 2);

    switch (langPrefix) {
      case 'en':
        final latinChars = RegExp(r'[a-zA-Z]').allMatches(text).length;
        return latinChars > totalChars * 0.7;

      case 'zh':
        final cjkChars = RegExp(r'[\u4e00-\u9fff]').allMatches(text).length;
        return cjkChars > totalChars * 0.5;

      case 'ja':
        final japaneseChars =
            RegExp(r'[\u3040-\u309F\u30A0-\u30FF\u4e00-\u9fff]')
                .allMatches(text)
                .length;
        return japaneseChars > totalChars * 0.5;

      case 'ko':
        final hangulChars =
            RegExp(r'[\uAC00-\uD7AF]').allMatches(text).length;
        return hangulChars > totalChars * 0.5;

      case 'es':
      case 'fr':
      case 'de':
      case 'it':
      case 'pt':
      case 'ru':
        final latinChars = RegExp(
                r'[a-zA-Zàáâäãåāăąçćčďđèéêëēėęěğǵḧîïíīįìłḿñńǹňôöòóœøōõőṕŕřßśšşșťțûüùúūǘůűųẃẍÿýžźż]')
            .allMatches(text)
            .length;
        return latinChars > totalChars * 0.6;

      default:
        return text.length > 15;
    }
  }

  static String extractLearningLanguageSentence(
      String line, String learningLanguage) {
    var text = line.replaceFirst(RegExp(r'^[\s]*([\-\*+]|\d+[\.)])\s+'), '');
    text = text.replaceFirst(RegExp(r'^(例[:：]|Example[:：]|Sample[:：])\s*'), '');

    final plainText =
        text.replaceAll(RegExp(r'\*\*'), '').replaceAll(RegExp(r'\*'), '');

    final withoutTranslation = _removeTranslation(plainText);

    if (isLanguageText(withoutTranslation, learningLanguage)) {
      return withoutTranslation.trim();
    }

    return '';
  }

  static String _removeTranslation(String text) {
    var result = text.replaceFirst(RegExp(r'\s*[（(][^)）]*[)）]\s*$'), '');
    result = result.replaceFirst(RegExp(r'\s+[—–-]\s+[^—–-]+$'), '');
    result = result.replaceFirst(RegExp(r'\s*[:：]\s*[^:：]+$'), '');
    return result.trim();
  }
}
