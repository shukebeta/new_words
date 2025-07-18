import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'word_list_item.dart';

class WordList extends StatefulWidget {
  final Map<String, List<WordExplanation>> groupedWords;
  final Function(WordExplanation) onItemTap;
  final Function(WordExplanation) onDelete;
  final VoidCallback onRefresh;
  final bool isLoading;
  final bool canLoadMore;
  final ScrollController scrollController;

  const WordList({
    super.key,
    required this.groupedWords,
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
  @override
  Widget build(BuildContext context) {
    final dates = widget.groupedWords.keys.toList();
    // Sort date strings in descending order (newest first)
    dates.sort((a, b) => b.compareTo(a));

    return RefreshIndicator(
      onRefresh: () async => widget.onRefresh(),
      child: ListView.builder(
        controller: widget.scrollController,
        itemCount: dates.length * 2 + (widget.canLoadMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (widget.canLoadMore && index == dates.length * 2) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (index.isEven) {
            final dateIndex = index ~/ 2;
            final dateKey = dates[dateIndex];
            return _buildDateHeader(dateKey);
          } else {
            final dateIndex = (index - 1) ~/ 2;
            final dateKey = dates[dateIndex];
            return _buildWordListForDate(
              widget.groupedWords[dateKey]!,
              context,
            );
          }
        },
      ),
    );
  }

  Widget _buildDateHeader(String dateKey) {
    // Parse the date string to DateTime for formatting
    final date = DateTime.parse(dateKey);
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

  Widget _buildWordListForDate(
    List<WordExplanation> words,
    BuildContext context,
  ) {
    return Column(
      children:
          words
              .map(
                (word) => WordListItem(
                  word: word,
                  onTap: () => widget.onItemTap(word),
                  onDelete: widget.onDelete,
                ),
              )
              .toList(),
    );
  }

  String _formatDate(DateTime date) {
    return '- ${DateFormat('EEEE, MMM d, yyyy').format(date)} -';
  }
}
