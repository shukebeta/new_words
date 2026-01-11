import 'package:flutter_test/flutter_test.dart';
import 'package:new_words/utils/markdown_parser.dart';

void main() {
  group('isLanguageText', () {
    test('English text returns true for en', () {
      expect(
        MarkdownParser.isLanguageText(
            'The architect designed a beautiful library.', 'en'),
        isTrue,
      );
    });

    test('Chinese text returns false for en', () {
      expect(
        MarkdownParser.isLanguageText('形容运动员的表现远超常规水平。', 'en'),
        isFalse,
      );
    });

    test('Mixed text with majority English returns true for en', () {
      expect(
        MarkdownParser.isLanguageText(
            'The performance was extraordinary, breaking records.', 'en'),
        isTrue,
      );
    });

    test('Mixed text with majority Chinese returns false for en', () {
      expect(
        MarkdownParser.isLanguageText(
            '描述实验结果或技术性能显著优于标准。', 'en'),
        isFalse,
      );
    });

    test('Chinese text returns true for zh-CN', () {
      expect(
        MarkdownParser.isLanguageText('形容运动员的表现远超常规水平。', 'zh-CN'),
        isTrue,
      );
    });

    test('Short text returns false', () {
      expect(
        MarkdownParser.isLanguageText('Hi there', 'en'),
        isFalse,
      );
    });
  });

  group('extractLearningLanguageSentence', () {
    test('List item with English sentence returns the sentence', () {
      final result = MarkdownParser.extractLearningLanguageSentence(
        '- The architect designed a beautiful new library for the city.',
        'en',
      );
      expect(result, 'The architect designed a beautiful new library for the city.');
    });

    test('List item with Chinese-only text returns empty for en', () {
      final result = MarkdownParser.extractLearningLanguageSentence(
        '- 形容运动员的表现远超常规水平。',
        'en',
      );
      expect(result, isEmpty);
    });

    test('List item with English + parenthesized Chinese returns English only',
        () {
      final result = MarkdownParser.extractLearningLanguageSentence(
        '- The performance was extraordinary. (表现非凡)',
        'en',
      );
      expect(result, 'The performance was extraordinary.');
    });

    test('Ordered list item works', () {
      final result = MarkdownParser.extractLearningLanguageSentence(
        '1. She has a sense of humor that always lifts the mood.',
        'en',
      );
      expect(result, 'She has a sense of humor that always lifts the mood.');
    });

    test('List with dash separator returns learning language part', () {
      final result = MarkdownParser.extractLearningLanguageSentence(
        '- The athlete broke the world record - 运动员打破了世界纪录',
        'en',
      );
      expect(result, 'The athlete broke the world record');
    });

    test('Chinese sentence returns correctly for zh-CN', () {
      final result = MarkdownParser.extractLearningLanguageSentence(
        '- 他的超凡能力让所有人惊叹。',
        'zh-CN',
      );
      expect(result, '他的超凡能力让所有人惊叹。');
    });

    test('List item with English + trailing Chinese (no separator) returns English only', () {
      final result = MarkdownParser.extractLearningLanguageSentence(
        '- English content here. 中文翻译内容',
        'en',
      );
      expect(result, 'English content here.');
    });
  });
}
