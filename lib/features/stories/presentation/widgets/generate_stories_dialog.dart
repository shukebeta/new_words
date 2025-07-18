import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:new_words/providers/stories_provider.dart';

class GenerateStoriesDialog extends StatefulWidget {
  const GenerateStoriesDialog({super.key});

  @override
  State<GenerateStoriesDialog> createState() => _GenerateStoriesDialogState();
}

class _GenerateStoriesDialogState extends State<GenerateStoriesDialog> {
  final TextEditingController _wordsController = TextEditingController();
  bool _useCustomWords = false;

  @override
  void dispose() {
    _wordsController.dispose();
    super.dispose();
  }

  List<String> _parseCustomWords(String input) {
    return input
        .split(',')
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  Future<void> _generateStories() async {
    final provider = Provider.of<StoriesProvider>(context, listen: false);

    List<String>? customWords;
    if (_useCustomWords && _wordsController.text.trim().isNotEmpty) {
      customWords = _parseCustomWords(_wordsController.text.trim());
      if (customWords.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter at least one word'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    try {
      final newStories = await provider.generateStories(
        customWords: customWords,
      );

      if (newStories != null && newStories.isNotEmpty) {
        if (mounted) {
          Navigator.of(context).pop(newStories); // Return the generated stories
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${newStories.length} ${newStories.length == 1 ? 'story' : 'stories'} generated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to generate stories: ${provider.generateError ?? e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<StoriesProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          title: const Text('Generate Stories'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create learning stories using vocabulary words in your learning language.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // Option 1: Use recent vocabulary
                RadioListTile<bool>(
                  title: const Text('Use Recent Vocabulary'),
                  subtitle: const Text(
                    'Generate stories from your recently added words',
                  ),
                  value: false,
                  groupValue: _useCustomWords,
                  onChanged: (value) {
                    setState(() {
                      _useCustomWords = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                // Option 2: Custom words
                RadioListTile<bool>(
                  title: const Text('Custom Words'),
                  subtitle: const Text('Specify your own words for the story'),
                  value: true,
                  groupValue: _useCustomWords,
                  onChanged: (value) {
                    setState(() {
                      _useCustomWords = value ?? false;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),

                // Custom words input
                if (_useCustomWords) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _wordsController,
                    decoration: const InputDecoration(
                      labelText: 'Words (comma-separated)',
                      hintText: 'adventure, mountain, discover',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !provider.isGenerating,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tip: Use 1-10 words for best results. More words will create multiple stories.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],

                // Error message
                if (provider.generateError != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      provider.generateError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed:
                  provider.isGenerating
                      ? null
                      : () {
                        Navigator.of(context).pop();
                      },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: provider.isGenerating ? null : _generateStories,
              child:
                  provider.isGenerating
                      ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Generating...'),
                        ],
                      )
                      : const Text('Generate'),
            ),
          ],
        );
      },
    );
  }
}
