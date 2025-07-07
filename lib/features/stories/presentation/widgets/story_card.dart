import 'package:flutter/material.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/features/stories/presentation/story_detail_screen.dart';
import 'package:new_words/utils/util.dart';

class StoryCard extends StatelessWidget {
  final Story story;

  const StoryCard({
    super.key,
    required this.story,
  });

  void _navigateToDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryDetailScreen(story: story),
      ),
    );
  }


  String _getPreviewContent(String content) {
    // Remove markdown bold syntax for preview
    final preview = content.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*'), (match) => match.group(1) ?? '');
    
    // Limit to first 150 characters
    if (preview.length <= 150) {
      return preview;
    }
    
    final truncated = preview.substring(0, 150);
    final lastSpace = truncated.lastIndexOf(' ');
    return lastSpace > 100 ? '${truncated.substring(0, lastSpace)}...' : '$truncated...';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with read status only
              Row(
                children: [
                  // Read status indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: story.isRead ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    story.isRead ? 'Read' : 'Unread',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: story.isRead ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Story content preview
              Text(
                _getPreviewContent(story.content),
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Vocabulary words
              if (story.vocabularyWords.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: story.vocabularyWords.take(5).map((word) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        word,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (story.vocabularyWords.length > 5)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${story.vocabularyWords.length - 5} more words',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
              ],
              
              // Footer with metadata
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Util.formatUnixTimestampToLocalDate(story.createdAt, 'MMM d, yyyy'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const Spacer(),
                  // Small favorite indicator (non-clickable)
                  if (story.isFavorited) ...[
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Favorite count from other users
                  if (story.favoriteCount > 0) ...[
                    Icon(
                      Icons.favorite_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${story.favoriteCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}