import 'package:flutter/material.dart';
import 'package:new_words/providers/vocabulary_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/features/add_word/presentation/add_word_dialog.dart';
import 'package:new_words/features/word_detail/presentation/word_detail_screen.dart';
import 'package:new_words/features/new_words_list/presentation/widgets/word_list.dart';
import 'package:new_words/utils/util.dart'; // Import for date formatting
import 'package:new_words/generated/app_localizations.dart';

class NewWordsListScreen extends StatefulWidget {
  const NewWordsListScreen({super.key});

  static const routeName = '/new-words-list';

  @override
  State<NewWordsListScreen> createState() => _NewWordsListScreenState();
}

class _NewWordsListScreenState extends State<NewWordsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<VocabularyProvider>(context, listen: false);
      if (provider.words.isEmpty) {
        provider.fetchWords();
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
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
    AddWordDialog.show(context);
  }

  void _navigateToWordDetail(BuildContext context, WordExplanation word) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WordDetailScreen(wordExplanation: word),
      ),
    );
  }

  Future<void> _deleteWord(BuildContext context, WordExplanation word) async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    final success = await provider.deleteWord(word.id);
    if (mounted && context.mounted) {
      if (success) {
        Util.showInfo(ScaffoldMessenger.of(context), 'Word deleted successfully');
      } else {
        Util.showError(ScaffoldMessenger.of(context), 'Failed to delete word');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.newWordsTitle),
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
                  Text('${AppLocalizations.of(context)!.errorPrefix} ${vocabularyProvider.listError}'),
                  ElevatedButton(
                    onPressed: () => _refreshWords(context),
                    child: Text(AppLocalizations.of(context)!.retryButton),
                  ),
                ],
              ),
            );
          }
          if (vocabularyProvider.words.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.noWordsYet),
                  ElevatedButton(
                    onPressed: () => _refreshWords(context),
                    child: Text(AppLocalizations.of(context)!.refreshButton),
                  ),
                ],
              ),
            );
          }

          return WordList(
            groupedWords: vocabularyProvider.groupedWords,
            onItemTap: (word) => _navigateToWordDetail(context, word),
            onDelete: (word) => _deleteWord(context, word),
            onRefresh: () => _refreshWords(context),
            isLoading: vocabularyProvider.isLoadingList,
            canLoadMore: vocabularyProvider.canLoadMore,
            scrollController: _scrollController, // Pass scroll controller
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddWord(context),
        tooltip: AppLocalizations.of(context)!.addNewWordTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}