import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/features/word_detail/presentation/word_detail_screen.dart';
import 'package:new_words/providers/memories_provider.dart';

class DailyWordsScreen extends StatefulWidget {
  final WordExplanation referenceWord;

  const DailyWordsScreen({super.key, required this.referenceWord});

  @override
  State<DailyWordsScreen> createState() => _DailyWordsScreenState();
}

class _DailyWordsScreenState extends State<DailyWordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MemoriesProvider>(context, listen: false);
      provider.loadWordsForWordDate(widget.referenceWord);
    });
  }

  Future<void> _refreshWords() async {
    final provider = Provider.of<MemoriesProvider>(context, listen: false);
    await provider.loadWordsForWordDate(widget.referenceWord);
  }

  void _navigateToWordDetail(WordExplanation word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetailScreen(wordExplanation: word),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Words')),
      body: Consumer<MemoriesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDate) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.dateError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load words',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.dateError!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshWords,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.dateWords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_note_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No words found',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'No words were learned on this date.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshWords,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Date header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.selectedDateString,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.dateWordsCount} word${provider.dateWordsCount != 1 ? 's' : ''} learned',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              // Words list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshWords,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.dateWords.length,
                    itemBuilder: (context, index) {
                      final word = provider.dateWords[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            word.wordText,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              MarkdownBody(
                                data: _truncateMarkdown(
                                  word.markdownExplanation,
                                ),
                                styleSheet: MarkdownStyleSheet(
                                  p: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: WrapAlignment.start,
                                ),
                              ),
                              if (word.providerModelName != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Generated by: ${word.providerModelName}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _navigateToWordDetail(word),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _truncateMarkdown(String markdown) {
    // Limit markdown length for preview while preserving formatting
    if (markdown.length > 200) {
      return '${markdown.substring(0, 200)}...';
    }
    return markdown;
  }
}
