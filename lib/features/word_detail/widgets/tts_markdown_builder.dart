import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/utils/markdown_parser.dart';

/// Widget that displays markdown with inline TTS buttons for sample sentences
class TtsMarkdownWidget extends StatefulWidget {
  final WordExplanation explanation;
  final Future<void> Function(String sentence) onSpeak;

  const TtsMarkdownWidget({
    super.key,
    required this.explanation,
    required this.onSpeak,
  });

  @override
  State<TtsMarkdownWidget> createState() => _TtsMarkdownWidgetState();
}

class _TtsMarkdownWidgetState extends State<TtsMarkdownWidget> {
  late List<String> _sentencesWithTts;
  late String _processedMarkdown;

  @override
  void initState() {
    super.initState();
    _sentencesWithTts = [];
    _processedMarkdown = _processMarkdown(
      widget.explanation.markdownExplanation,
      widget.explanation.learningLanguage,
      _sentencesWithTts,
    );
  }

  @override
  void didUpdateWidget(TtsMarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.explanation != widget.explanation) {
      _sentencesWithTts.clear();
      _processedMarkdown = _processMarkdown(
        widget.explanation.markdownExplanation,
        widget.explanation.learningLanguage,
        _sentencesWithTts,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TtsMarkdownBody(
      data: _processedMarkdown,
      selectable: true,
      sentencesWithTts: _sentencesWithTts,
      onSpeak: widget.onSpeak,
    );
  }

  /// Process markdown to mark TTS sentences with bold emoji markers
  String _processMarkdown(
    String markdown,
    String learningLanguage,
    List<String> sentencesWithTts,
  ) {
    final lines = markdown.split('\n');
    final processed = <String>[];

    for (final line in lines) {
      // Check if this is a list item (unordered or ordered)
      if (_isListItem(line)) {
        final sentence = MarkdownParser.extractLearningLanguageSentence(line, learningLanguage);
        if (sentence.isNotEmpty) {
          sentencesWithTts.add(sentence);
          // Add a bold emoji marker at the end
          processed.add('$line **🔊**');
          continue;
        }
      }
      processed.add(line);
    }

    return processed.join('\n');
  }

  /// Check if line is a markdown list item
  bool _isListItem(String line) {
    final trimmed = line.trimLeft();
    // Unordered list: -, *, +
    if (RegExp(r'^[\-\*+]\s+').hasMatch(trimmed)) return true;
    // Ordered list: 1. 2. 3. etc.
    if (RegExp(r'^\d+[\.\)]\s+').hasMatch(trimmed)) return true;
    return false;
  }
}

/// Custom MarkdownBody that handles TTS for speaker buttons
class _TtsMarkdownBody extends StatefulWidget {
  final String data;
  final bool selectable;
  final List<String> sentencesWithTts;
  final Future<void> Function(String sentence) onSpeak;

  const _TtsMarkdownBody({
    required this.data,
    required this.selectable,
    required this.sentencesWithTts,
    required this.onSpeak,
  });

  @override
  State<_TtsMarkdownBody> createState() => _TtsMarkdownBodyState();
}

class _TtsMarkdownBodyState extends State<_TtsMarkdownBody> {
  int _buttonIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Reset button counter for each build
    _buttonIndex = 0;

    return MarkdownBody(
      data: widget.data,
      selectable: widget.selectable,
      builders: {
        'strong': _TtsStrongBuilder(
          sentencesWithTts: widget.sentencesWithTts,
          onSpeak: widget.onSpeak,
          onButtonRendered: () {
            final index = _buttonIndex;
            _buttonIndex++;
            return index;
          },
        ),
      },
    );
  }
}

/// Custom strong builder that converts 🔊 emoji to clickable buttons
class _TtsStrongBuilder extends MarkdownElementBuilder {
  final List<String> sentencesWithTts;
  final Future<void> Function(String sentence) onSpeak;
  final int Function() onButtonRendered;

  _TtsStrongBuilder({
    required this.sentencesWithTts,
    required this.onSpeak,
    required this.onButtonRendered,
  });

  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final text = _getElementText(element);

    if (text.trim() == '🔊') {
      final index = onButtonRendered();
      if (index >= 0 && index < sentencesWithTts.length) {
        final sentence = sentencesWithTts[index];

        return GestureDetector(
          onTap: () => onSpeak(sentence),
          child: const Padding(
            padding: EdgeInsets.only(left:4, right:4),
            child: Icon(
              Icons.volume_up,
              size: 16,
              color: Colors.blue,
            ),
          ),
        );
      }
    }

    final defaultWidget = super.visitElementAfterWithContext(
      context,
      element,
      preferredStyle,
      parentStyle,
    );
    return defaultWidget ?? const SizedBox.shrink();
  }

  /// Get text content from an element
  String _getElementText(md.Element element) {
    final buffer = StringBuffer();

    void traverse(md.Node? node) {
      if (node == null) return;
      if (node is md.Text) {
        buffer.write(node.text);
      } else if (node is md.Element) {
        final children = element.children;
        if (children != null) {
          for (final child in children) {
            traverse(child);
          }
        }
      }
    }

    traverse(element);
    return buffer.toString();
  }
}
