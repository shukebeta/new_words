import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/features/memories/presentation/daily_words_screen.dart';
import 'package:new_words/features/word_detail/presentation/word_detail_screen.dart';
import 'package:new_words/providers/memories_provider.dart';
import 'package:new_words/generated/app_localizations.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  bool _hasLoadedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedData) return;

    // Lazy loading: Load data only when this page is first accessed
    _hasLoadedData = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = Provider.of<MemoriesProvider>(context, listen: false);
      if (provider.memoryWords.isEmpty && !provider.isLoadingMemories) {
        provider.loadSpacedRepetitionWords();
      }
    });
  }

  Future<void> _refreshMemories() async {
    await Provider.of<MemoriesProvider>(
      context,
      listen: false,
    ).refreshMemories();
  }

  void _navigateToWordDetail(WordExplanation word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetailScreen(wordExplanation: word),
      ),
    );
  }

  void _navigateToDailyWords(WordExplanation word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DailyWordsScreen(referenceWord: word),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.memoriesTitle)),
      body: Consumer<MemoriesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingMemories && provider.memoryWords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.memoriesError != null && provider.memoryWords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.failedToLoadMemories,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.memoriesError!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshMemories,
                    child: Text(AppLocalizations.of(context)!.retryButton),
                  ),
                ],
              ),
            );
          }

          if (provider.memoryWords.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.psychology_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noMemoriesYet,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.startLearningWords,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshMemories,
                    child: Text(AppLocalizations.of(context)!.refreshButton),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refreshMemories,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.memoryWords.length,
              itemBuilder: (context, index) {
                final word = provider.memoryWords[index];
                final spacedRepetitionText = provider.getSpacedRepetitionText(
                  word,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Clickable title with word and arrow
                        GestureDetector(
                          onTap: () => _navigateToDailyWords(word),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$spacedRepetitionText - ${word.wordText}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Theme.of(context).colorScheme.primary,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Explanation content - clickable to go to word detail
                        GestureDetector(
                          onTap: () => _navigateToWordDetail(word),
                          child: MarkdownBody(
                            data: _truncateMarkdown(word.markdownExplanation),
                            styleSheet: MarkdownStyleSheet(
                              p: Theme.of(context).textTheme.bodyMedium,
                              textAlign: WrapAlignment.start,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _truncateMarkdown(String markdown) {
    // Limit markdown length for preview while preserving formatting
    if (markdown.length > 150) {
      return '${markdown.substring(0, 150)}...';
    }
    return markdown;
  }
}
