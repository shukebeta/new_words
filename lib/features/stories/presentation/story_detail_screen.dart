import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:new_words/app_config.dart';
import 'package:new_words/entities/story.dart';
import 'package:new_words/providers/stories_provider.dart';
import 'package:new_words/utils/util.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    
    // Mark as read when screen opens (only if not already read)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.story.isRead) {
        final provider = Provider.of<StoriesProvider>(context, listen: false);
        provider.markAsReadIfNeeded(widget.story);
      }
    });
  }

  // Get the current story from provider or fall back to widget.story
  Story getCurrentStory(StoriesProvider provider) {
    // Try to find updated story in provider's lists
    Story? updatedStory;
    
    // Check in my stories
    updatedStory = provider.myStories.where((s) => s.id == widget.story.id).firstOrNull;
    if (updatedStory != null) return updatedStory;
    
    // Check in story square
    updatedStory = provider.storySquare.where((s) => s.id == widget.story.id).firstOrNull;
    if (updatedStory != null) return updatedStory;
    
    // Check in favorites
    updatedStory = provider.favoriteStories.where((s) => s.id == widget.story.id).firstOrNull;
    if (updatedStory != null) return updatedStory;
    
    // Fall back to original story
    return widget.story;
  }

  void _toggleFavorite() {
    final provider = Provider.of<StoriesProvider>(context, listen: false);
    final story = getCurrentStory(provider);
    provider.toggleFavorite(story);
  }

  void _shareStory() {
    final provider = Provider.of<StoriesProvider>(context, listen: false);
    final story = getCurrentStory(provider);
    final shareText = '${story.content}\n\nVocabulary: ${story.storyWords}';
    
    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Story copied to clipboard!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _regenerateStory() async {
    final provider = Provider.of<StoriesProvider>(context, listen: false);
    final story = getCurrentStory(provider);
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Story'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will generate new stories using the same vocabulary words:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,  
              runSpacing: 4,
              children: story.vocabularyWords.map((word) => Chip(
                label: Text(word),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              )).toList(),
            ),
            const SizedBox(height: 12),
            const Text('This may take a few minutes. Continue?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final newStories = await provider.regenerateStoriesFromExisting(story);
        
        if (newStories != null && newStories.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${newStories.length} new ${newStories.length == 1 ? 'story' : 'stories'} generated!',
              ),
              backgroundColor: Colors.green,
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to stories list
                },
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to regenerate stories: ${provider.generateError ?? e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        final story = getCurrentStory(provider);
        
        return Scaffold(
          appBar: AppBar(
            title: const Text('Story'),
            actions: [
              IconButton(
                icon: Icon(
                  story.isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: story.isFavorited ? Colors.red : null,
                ),
                onPressed: _toggleFavorite,
                tooltip: story.isFavorited ? 'Remove from favorites' : 'Add to favorites',
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: _shareStory,
                tooltip: 'Share story',
              ),
              // Show regenerate button only in non-production environments
              if (!AppConfig.isProduction)
                Consumer<StoriesProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      icon: provider.isGenerating 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh),
                      onPressed: provider.isGenerating ? null : _regenerateStory,
                      tooltip: 'Regenerate with same words',
                    );
                  },
                ),
            ],
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Story metadata
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: story.isRead ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        story.isRead ? 'Read' : 'Unread',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: story.isRead ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (story.favoriteCount > 0) ...[
                        Icon(
                          Icons.favorite,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created ${Util.formatUnixTimestampToLocalDate(story.createdAt, 'MMM d, yyyy \'at\' h:mm a')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (story.firstReadAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Read ${Util.formatUnixTimestampToLocalDate(story.firstReadAt!, 'MMM d, yyyy \'at\' h:mm a')}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (story.providerModelName != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.smart_toy,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Generated by ${story.providerModelName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Vocabulary words section
            if (story.vocabularyWords.isNotEmpty) ...[
              Text(
                'Vocabulary Words',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: story.vocabularyWords.map((word) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      word,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            
            // Story content
            Text(
              'Story',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Use MarkdownBody to render the story with bold vocabulary words
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: MarkdownBody(
                data: story.content,
                styleSheet: MarkdownStyleSheet(
                  p: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                    fontSize: 16,
                  ),
                  strong: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                selectable: true,
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
        );
      },
    );
  }
}