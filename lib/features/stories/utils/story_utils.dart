import 'package:new_words/entities/story.dart';

class StoryUtils {
  /// Extracts vocabulary words from a story's content by finding words wrapped in **bold** or __underline__ markdown
  static List<String> extractVocabularyFromContent(String content) {
    final Set<String> words = {};

    // Extract from **bold** syntax
    final RegExp boldWordRegex = RegExp(r'\*\*(.*?)\*\*');
    final Iterable<RegExpMatch> boldMatches = boldWordRegex.allMatches(content);
    words.addAll(boldMatches
        .map((match) => match.group(1)?.trim() ?? '')
        .where((word) => word.isNotEmpty));

    // Extract from __underline__ syntax
    final RegExp underlineWordRegex = RegExp(r'__(.+?)__');
    final Iterable<RegExpMatch> underlineMatches = underlineWordRegex.allMatches(content);
    words.addAll(underlineMatches
        .map((match) => match.group(1)?.trim() ?? '')
        .where((word) => word.isNotEmpty));

    return words.toList();
  }

  /// Formats a story preview by removing markdown and limiting length
  static String getStoryPreview(String content, {int maxLength = 150}) {
    // Remove markdown bold and underline syntax for preview
    String preview = content.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '');
    preview = preview.replaceAllMapped(RegExp(r'__(.+?)__'), (match) => match.group(1) ?? '');

    // Limit to specified length
    if (preview.length <= maxLength) {
      return preview;
    }

    final truncated = preview.substring(0, maxLength);
    final lastSpace = truncated.lastIndexOf(' ');
    return lastSpace > maxLength * 0.7
        ? '${truncated.substring(0, lastSpace)}...'
        : '$truncated...';
  }

  /// Preprocesses story content to handle both bold (**text**) and underline (__text__) syntax
  static String preprocessMarkdown(String content) {
    // Convert __text__ to a custom syntax that we can style differently
    // We'll use a temporary placeholder that won't conflict with normal text
    return content.replaceAllMapped(RegExp(r'__(.+?)__'), (match) {
      final word = match.group(1) ?? '';
      return '<u>$word</u>'; // Use HTML-like syntax for underline
    });
  }

  /// Checks if a story contains specific vocabulary words
  static bool containsVocabulary(Story story, List<String> words) {
    final storyWords =
        story.vocabularyWords.map((w) => w.toLowerCase()).toSet();
    return words.any((word) => storyWords.contains(word.toLowerCase()));
  }

  /// Groups stories by their creation date
  static Map<String, List<Story>> groupStoriesByDate(List<Story> stories) {
    final Map<String, List<Story>> grouped = {};

    for (final story in stories) {
      final date = DateTime.fromMillisecondsSinceEpoch(story.createdAt * 1000);
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(story);
    }

    return grouped;
  }
}
