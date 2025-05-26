import 'package:flutter/material.dart';
import 'package:new_words/providers/vocabulary_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/word_explanation.dart'; // Import WordExplanation
import 'package:new_words/features/add_word/presentation/add_word_dialog.dart'; // Import the dialog
import 'package:new_words/features/word_detail/presentation/word_detail_screen.dart'; // Import the detail screen


class NewWordsListScreen extends StatefulWidget {
  const NewWordsListScreen({super.key});

  static const routeName = '/new-words-list'; // Example route name

  @override
  State<NewWordsListScreen> createState() => _NewWordsListScreenState();
}

class _NewWordsListScreenState extends State<NewWordsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial words
    // Use addPostFrameCallback to ensure provider is available if screen is built immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<VocabularyProvider>(context, listen: false);
      if (provider.words.isEmpty) { // Fetch only if list is empty initially
        provider.fetchWords();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && // Trigger before reaching the very end
          !Provider.of<VocabularyProvider>(context, listen: false).isLoadingList &&
          Provider.of<VocabularyProvider>(context, listen: false).canLoadMore) {
        Provider.of<VocabularyProvider>(context, listen: false).fetchWords(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshWords(BuildContext context) async {
    await Provider.of<VocabularyProvider>(context, listen: false).fetchWords();
  }

  void _navigateToAddWord(BuildContext context) async {
    // Option 1: Navigate to a new screen
    // Navigator.of(context).pushNamed(AddWordScreen.routeName);
    AddWordDialog.show(context);
  }

  void _navigateToWordDetail(BuildContext context, WordExplanation word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetailScreen(wordExplanation: word),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('New Words'), // Changed title
      ),
      body: Consumer<VocabularyProvider>(
        builder: (ctx, vocabularyProvider, child) {
          if (vocabularyProvider.isLoadingList && vocabularyProvider.words.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vocabularyProvider.listError != null && vocabularyProvider.words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${vocabularyProvider.listError}'),
                  ElevatedButton(
                    onPressed: () => _refreshWords(context),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (vocabularyProvider.words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Corrected: Added mainAxisAlignment parameter name
                children: [
                  const Text('No words added yet. Tap + to add your first word!'),
                   ElevatedButton( // Added retry here as well if list is empty after initial load
                    onPressed: () => _refreshWords(context),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshWords(context),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: vocabularyProvider.words.length + (vocabularyProvider.canLoadMore ? 1 : 0),
              itemBuilder: (ctx, index) {
                if (index == vocabularyProvider.words.length) {
                  // This is the loading indicator for "load more"
                  return vocabularyProvider.isLoadingList 
                      ? const Center(child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ))
                      : const SizedBox.shrink(); // Or some other indicator that more can be loaded
                }
                final word = vocabularyProvider.words[index];
                String markdownPreview = word.markdownExplanation.replaceAll('\n', ' '); // Replace newlines with spaces
                if (markdownPreview.length > 80) {
                  markdownPreview = '${markdownPreview.substring(0, 80)}...';
                }
                // Further stripping of markdown characters for preview might be desired
                // For simplicity, this example just truncates.
                // Consider using a regex to remove markdown syntax for a cleaner preview.
                // e.g., markdownPreview = markdownPreview.replaceAll(RegExp(r'[#*`~_\[\]\(\)!-]'), '');


                return ListTile(
                  title: Text(word.wordText),
                  subtitle: Text(
                    '${word.wordLanguage} ➔ ${word.explanationLanguage}  $markdownPreview',
                    maxLines: 2, // Allow subtitle to wrap if needed
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _navigateToWordDetail(context, word),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddWord(context),
        tooltip: 'Add New Word',
        child: const Icon(Icons.add),
      ),
    );
  }
}