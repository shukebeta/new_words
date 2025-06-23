import 'package:new_words/entities/story.dart';

class StoryUtils {
  /// Extracts vocabulary words from a story's content by finding words wrapped in **bold** markdown
  static List<String> extractVocabularyFromContent(String content) {
    final RegExp boldWordRegex = RegExp(r'\*\*(.*?)\*\*');
    final Iterable<RegExpMatch> matches = boldWordRegex.allMatches(content);
    
    return matches
        .map((match) => match.group(1)?.trim() ?? '')
        .where((word) => word.isNotEmpty)
        .toSet() // Remove duplicates
        .toList();
  }

  /// Formats a story preview by removing markdown and limiting length
  static String getStoryPreview(String content, {int maxLength = 150}) {
    // Remove markdown bold syntax for preview
    final preview = content.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '');
    
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

  /// Checks if a story contains specific vocabulary words
  static bool containsVocabulary(Story story, List<String> words) {
    final storyWords = story.vocabularyWords.map((w) => w.toLowerCase()).toSet();
    return words.any((word) => storyWords.contains(word.toLowerCase()));
  }

  /// Groups stories by their creation date
  static Map<String, List<Story>> groupStoriesByDate(List<Story> stories) {
    final Map<String, List<Story>> grouped = {};
    
    for (final story in stories) {
      final date = DateTime.fromMillisecondsSinceEpoch(story.createdAt * 1000);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(story);
    }
    
    return grouped;
  }
}