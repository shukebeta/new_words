import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/features/add_word/presentation/add_word_dialog.dart';
// import 'package:url_launcher/url_launcher.dart'; // For opening links in markdown, if needed

class WordDetailScreen extends StatelessWidget {
  final WordExplanation wordExplanation;

  const WordDetailScreen({super.key, required this.wordExplanation});

  static const routeName = '/word-detail'; // Example route name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(wordExplanation.wordText),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              wordExplanation.wordText,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${wordExplanation.wordLanguage}  ➔  ${wordExplanation.explanationLanguage}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
            ),
            // Model name display removed as per feedback
            const SizedBox(height: 16),
            const Text(
              'Explanation:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            MarkdownBody(
              data: wordExplanation.markdownExplanation,
              // selectable: true, // Allows text selection
              // onTapLink: (text, href, title) { // Optional: handle link taps
              //   if (href != null) {
              //     launchUrl(Uri.parse(href));
              //   }
              // },
            ),
            // Optionally display other fields like pronunciation, definitions, examples
            // if (wordExplanation.pronunciation != null) ...[],
            // if (wordExplanation.definitions != null) ...[],
            // if (wordExplanation.examples != null) ...[],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async => AddWordDialog.show(context, replacePage: true),
        tooltip: 'Add New Word',
        child: const Icon(Icons.add),
      ),
    );
  }
}