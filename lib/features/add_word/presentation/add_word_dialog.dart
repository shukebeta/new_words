import 'package:flutter/material.dart';
import 'package:new_words/providers/vocabulary_provider.dart';
import 'package:provider/provider.dart';

class AddWordDialog extends StatefulWidget {
  const AddWordDialog({super.key});

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
    
    provider.addNewWord(_wordText).then((success) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        Navigator.of(context).pop();
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
      title: const Text('Add New Word'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          initialValue: _wordText,
          decoration: const InputDecoration(labelText: 'Word'),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a word.';
            }
            return null;
          },
          onSaved: (value) {
            _wordText = value ?? '';
          },
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
              : const Text('Add Word'),
        ),
      ],
    );
  }
}