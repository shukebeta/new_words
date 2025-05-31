import 'package:flutter/material.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'word_list_item.dart';
import '../new_words_list_screen.dart'; // Import for _NewWordsListScreenState

class WordList extends StatefulWidget {
  final Map<DateTime, List<WordExplanation>> groupedWords;
  final Function(WordExplanation) onItemTap;
  final VoidCallback onRefresh;
  final bool isLoading;
  final bool canLoadMore;
  final ScrollController scrollController; // Added scroll controller

  const WordList({
    super.key,
    required this.groupedWords,
    required this.onItemTap,
    required this.onRefresh,
    required this.scrollController, // Added scroll controller
    this.isLoading = false,
    this.canLoadMore = false,
  });

  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  @override
  Widget build(BuildContext context) {
    final dates = widget.groupedWords.keys.toList();
    dates.sort((a, b) => b.compareTo(a)); // sort dates in descending order

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        controller: widget.scrollController, // Use the scroll controller
        itemCount: dates.length * 2 + (widget.canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          // For load more indicator at the end
          if (widget.canLoadMore && index == dates.length * 2) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Even indices are headers, odd indices are the list for that date
          if (index.isEven) {
            final dateIndex = index ~/ 2;
            final date = dates[dateIndex];
            return _buildDateHeader(date);
          } else {
            final dateIndex = (index - 1) ~/ 2;
            final date = dates[dateIndex];
            return _buildWordListForDate(widget.groupedWords[date]!, context);
          }
        },
      ),
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        _formatDate(date),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildWordListForDate(List<WordExplanation> words, BuildContext context) {
    return Column(
      children: words.map((word) => WordListItem(
        word: word,
        onTap: () => widget.onItemTap(word),
      )).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      // Use the same date formatting as Happy Notes
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}