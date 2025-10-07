import 'package:flutter/material.dart';
import 'package:new_words/features/add_word/presentation/add_word_dialog.dart';
import 'package:new_words/generated/app_localizations.dart';

/// Shared floating action button for adding new words
///
/// This widget provides a consistent, semi-transparent FAB across the app
/// that opens the AddWordDialog when tapped.
class AddWordFab extends StatelessWidget {
  const AddWordFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.85,
      child: FloatingActionButton(
        onPressed: () => AddWordDialog.show(context),
        tooltip: AppLocalizations.of(context)!.addNewWordTooltip,
        child: const Icon(Icons.add),
      ),
    );
  }
}
