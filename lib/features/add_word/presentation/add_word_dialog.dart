import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/common_input_dialog.dart';
import '../../../providers/vocabulary_provider.dart';
import '../../word_detail/presentation/word_detail_screen.dart';

class AddWordDialog {
  // Remove the widget implementation entirely - this should only be a utility class

  /// Show the add word dialog and handle the result
  static Future<void> show(BuildContext context, {bool useReplace = false}) async {
    final result = await CommonInputDialog.show(
      context,
      title: 'Enter a word',
      validators: [
        InputValidators.required('Please enter a word.'),
        InputValidators.maxLength(100, 'Word cannot exceed 100 characters.'),
        InputValidators.containsLetter('Word must contain at least one letter.'),
      ],
    );

    if (result != null && result.isNotEmpty) {
      await _handleWordSubmission(context, result, useReplace);
    }
  }

  static Future<void> _handleWordSubmission(
      BuildContext context,
      String wordText,
      bool useReplace,
      ) async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);

    try {
      final addedWord = await provider.addNewWord(wordText);

      if (!context.mounted) return;

      if (addedWord != null) {
        if (useReplace) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => WordDetailScreen(wordExplanation: addedWord),
            ),
          );
        } else {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => WordDetailScreen(wordExplanation: addedWord),
            ),
          );
          if (context.mounted) {
            await Provider.of<VocabularyProvider>(context, listen: false)
                .refreshWords();
          }
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Word "$wordText" added successfully!')),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.addError ?? 'Failed to add word. Please try again.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An unexpected error occurred: $error'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}