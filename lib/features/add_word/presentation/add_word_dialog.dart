import 'package:flutter/material.dart';
import 'package:new_words/providers/vocabulary_provider.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/features/word_detail/presentation/word_detail_screen.dart';

class AddWordDialog extends StatefulWidget {
  final bool useReplace;
  
  const AddWordDialog({super.key, this.useReplace = false});

  @override
  State<AddWordDialog> createState() => _AddWordDialogState();
}

class _AddWordDialogState extends State<AddWordDialog> {
  final _formKey = GlobalKey<FormState>();
  String _wordText = '';
  bool _isSubmitting = false;

  void _submitForm() { // Made non-async
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    _formKey.currentState?.save();

    setState(() {
      _isSubmitting = true;
    });

    final provider = Provider.of<VocabularyProvider>(context, listen: false);
    
    provider.addNewWord(_wordText).then((addedWord) async {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (addedWord != null) {
        Navigator.of(context).pop();
        if (widget.useReplace) {
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
          if (mounted) {
            await Provider.of<VocabularyProvider>(context, listen: false).refreshWords();
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Word "$_wordText" added successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.addError ?? 'Failed to add word. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }).catchError((error) {
        if (!mounted) return;
        setState(() {
            _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('An unexpected error occurred: $error'),
                backgroundColor: Theme.of(context).colorScheme.error,
            ),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to isLoadingAdd from provider to disable UI during submission
    // This is an alternative to the local _isSubmitting if provider updates UI immediately
    // final isLoadingFromProvider = context.watch<VocabularyProvider>().isLoadingAdd;

    return AlertDialog(
      title: const Text('Enter a word'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: _wordText,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a word.';
            }
            if (value.trim().length > 100) { // Max length check
              return 'Word cannot exceed 100 characters.';
            }
            // Basic check for at least one letter to avoid only symbols/numbers, can be refined
            if (!value.trim().contains(RegExp(r'[a-zA-Z\p{L}]', unicode: true))) {
                return 'Word must contain at least one letter.';
            }
            return null;
          },
          onSaved: (value) {
            _wordText = value ?? '';
          },
          onFieldSubmitted: (_) { // Added onFieldSubmitted
            if (!_isSubmitting) {
              _submitForm();
            }
          },
          textInputAction: TextInputAction.done, // Show 'done' action on keyboard
          enabled: !_isSubmitting, // Disable if submitting
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Go'),
        ),
      ],
    );
  }
}