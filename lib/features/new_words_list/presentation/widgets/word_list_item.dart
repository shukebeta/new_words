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
    final timeString = _formatTime(word.createdAt);
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '- $timeString - ${word.wordText} ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: Colors.blue,
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey.shade300,
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            MarkdownBody(
              data: _truncateMarkdownPreview(word.markdownExplanation),
              styleSheet: MarkdownStyleSheet(
                p: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final localTime = dateTime.toLocal();
    return '${localTime.hour}:${localTime.minute.toString().padLeft(2, '0')}';
  }

  String _truncateMarkdownPreview(String markdown) {
    // Remove newlines and truncate preview
    return markdown.length > maxPreviewLength
        ? '${markdown.substring(0, maxPreviewLength)}...'
        : markdown;
  }
}