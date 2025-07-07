import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/widgets/common_input_dialog.dart';
import '../../../entities/word_explanation.dart';
import '../../../providers/vocabulary_provider.dart';
import '../../../utils/input_validators.dart';
import '../../../utils/util.dart';
import '../../word_detail/presentation/word_detail_screen.dart';

class AddWordDialog {
  static Future<void> show(BuildContext context, {bool replacePage = false}) async {
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
          return await provider.addNewWord(word);
        } catch (e) {
          if (context.mounted) {
            Util.showError(ScaffoldMessenger.of(context), "Couldn't add word: ${e.toString()}");
          }
        }
      },
    );

    if (result is WordExplanation && context.mounted) {
      if (replacePage) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WordDetailScreen(wordExplanation: result),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WordDetailScreen(wordExplanation: result),
          ),
        );
      }
    }
  }
}