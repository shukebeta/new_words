import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/common_input_dialog.dart';
import '../../../entities/word_explanation.dart';
import '../../../providers/vocabulary_provider.dart';
import '../../../utils/input_validators.dart';
import '../../../utils/util.dart';
import '../../word_detail/presentation/word_detail_screen.dart';

class AddWordDialog {
  static Future<void> show(BuildContext context, {bool useReplace = false}) async {
    final result = await CommonInputDialog.show(
      context,
      title: 'Got a new word?',
      validators: [
        InputValidators.required('Enter a word or phrase.'),
        InputValidators.maxLength(100, 'Too long -- 100 characters max.'),
        InputValidators.containsLetter('Needs at least one letter.'),
      ],
      onConfirm: (word) async {
        try {
          final provider = Provider.of<VocabularyProvider>(context, listen: false);
          final result = await provider.addNewWord(word);
          return result;
        } catch (e) {
          throw Exception("Couldn't add word: ${e.toString()}");
        }
      },
    );

    if (result != null && result is WordExplanation) {
      _handleSuccess(context, result, useReplace);
    } else if (result != null && result is Exception) {
      _handleError(context, result);
    }
  }

  static void _handleError(BuildContext context, Exception error) {
    Util.showError(ScaffoldMessenger.of(context), error.toString());
  }

  static void _handleSuccess(
    BuildContext context,
    WordExplanation addedWord,
    bool useReplace,
  ) {
    if (useReplace) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => WordDetailScreen(wordExplanation: addedWord),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => WordDetailScreen(wordExplanation: addedWord),
        ),
      );
    }
  }
}