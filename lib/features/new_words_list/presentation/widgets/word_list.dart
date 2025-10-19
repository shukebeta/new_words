import 'package:flutter/material.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/utils/util.dart';
import 'word_list_item.dart';

class WordList extends StatefulWidget {
  final List<WordExplanation> words;
  final Function(WordExplanation) onItemTap;
  final Function(WordExplanation) onDelete;
  final VoidCallback onRefresh;
  final bool isLoading;
  final bool canLoadMore;
  final ScrollController scrollController;

  const WordList({
    super.key,
    required this.words,
    required this.onItemTap,
    required this.onDelete,
    required this.onRefresh,
    required this.scrollController,
    this.isLoading = false,
    this.canLoadMore = false,
  });

  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  String? _getDateIfFirstOfDay(int index, List<WordExplanation> words) {
    if (index < 0 || index >= words.length) return null;
    
    final currentWord = words[index];
    final currentDate = Util.formatUnixTimestampToLocalDate(
      currentWord.updatedAt,
      'yyyy-MM-dd',
    );
    
    // Show date if this is the first word or if date changed from previous word
    if (index == 0) {
      return currentDate;
    }
    
    final previousWord = words[index - 1];
    final previousDate = Util.formatUnixTimestampToLocalDate(
      previousWord.updatedAt,
      'yyyy-MM-dd',
    );
    
    return currentDate != previousDate ? currentDate : null;
  }

  @override
  Widget build(BuildContext context) {
    // Use words directly as backend provides sorted data, and new words are inserted at index 0
    final allWords = widget.words;

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: allWords.length + (widget.canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (widget.canLoadMore && index == allWords.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final word = allWords[index];
          final dateLabel = _getDateIfFirstOfDay(index, allWords);
          
          return WordListItem(
            word: word,
            dateLabel: dateLabel,
            onTap: () => widget.onItemTap(word),
            onDelete: widget.onDelete,
          );
        },
      ),
    );
  }
}
