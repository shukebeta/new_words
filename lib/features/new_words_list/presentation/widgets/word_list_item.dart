import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:new_words/entities/word_explanation.dart';

class WordListItem extends StatelessWidget {
  final WordExplanation word;
  final VoidCallback onTap;
  final int maxPreviewLength;

  const WordListItem({
    super.key,
    required this.word,
    required this.onTap,
    this.maxPreviewLength = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(word.wordText),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render Markdown preview using flutter_markdown
          MarkdownBody(
            data: _truncateMarkdownPreview(word.markdownExplanation),
            styleSheet: MarkdownStyleSheet(
              p: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  String _truncateMarkdownPreview(String markdown) {
    // Remove newlines and truncate preview
    return markdown.length > maxPreviewLength
        ? '${markdown.substring(0, maxPreviewLength)}...'
        : markdown;
  }
}