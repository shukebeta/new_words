import 'package:flutter/material.dart';
import 'package:new_words/features/new_words_list/models/word_model.dart';
import 'package:new_words/features/new_words_list/services/vocabulary_service.dart';
// import 'package:new_words/utils/util.dart'; // For showInfo/showError

class AddWordScreen extends StatefulWidget {
  static const String routeName = '/add-word';

  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordTextController = TextEditingController();
  final _wordLanguageController = TextEditingController(text: 'en'); // Default to English
  final _explanationLanguageController = TextEditingController(text: 'zh-CN'); // Default to user's native
  final _markdownExplanationController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _definitionsController = TextEditingController();
  final _examplesController = TextEditingController();
  final _providerModelNameController = TextEditingController();


  final VocabularyService _vocabularyService = VocabularyService();
  bool _isSaving = false;

  // TODO: Fetch user's actual native and learning languages from user settings/profile
  // For now, using defaults. These should be populated from a user profile service.
  String _currentUserLearningLanguage = 'en'; 
  String _currentUserNativeLanguage = 'zh-CN';


  @override
  void initState() {
    super.initState();
    // Pre-fill based on user settings if available
    _wordLanguageController.text = _currentUserLearningLanguage;
    _explanationLanguageController.text = _currentUserNativeLanguage;
  }


  Future<void> _saveWord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final newWord = Word(
        wordId: 0, // Backend will assign ID
        wordText: _wordTextController.text.trim(),
        wordLanguage: _wordLanguageController.text.trim(),
        explanationLanguage: _explanationLanguageController.text.trim(),
        markdownExplanation: _markdownExplanationController.text.trim(),
        pronunciation: _pronunciationController.text.trim().isNotEmpty ? _pronunciationController.text.trim() : null,
        definitions: _definitionsController.text.trim().isNotEmpty ? _definitionsController.text.trim() : null,
        examples: _examplesController.text.trim().isNotEmpty ? _examplesController.text.trim() : null,
        createdAt: DateTime.now().millisecondsSinceEpoch, // Client-side timestamp, backend might override
        providerModelName: _providerModelNameController.text.trim().isNotEmpty ? _providerModelNameController.text.trim() : null,
      );

      try {
        final addedWord = await _vocabularyService.addWord(newWord);
        if (mounted) {
          // showInfo(context, 'Word "${addedWord.wordText}" added successfully!');
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Word "${addedWord.wordText}" added successfully!')),
          );
          Navigator.pop(context, true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          // showError(context, 'Failed to add word: ${e.toString()}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add word: ${e.toString()}')),
          );
          // If error indicates language mismatch, show a confirmation dialog as per plan
          if (e.toString().toLowerCase().contains("language mismatch") || 
              e.toString().toLowerCase().contains("does not match your learning language")) {
            _showLanguageMismatchDialog(newWord);
          }
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  void _showLanguageMismatchDialog(Word wordToConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Language Mismatch?'),
          content: Text(
              "The language of the word you entered ('${wordToConfirm.wordLanguage}') "
              "seems different from your current learning language ('$_currentUserLearningLanguage').\n\n"
              "Do you want to add it anyway as a '${wordToConfirm.wordLanguage}' word, "
              "or would you like to correct the language to '$_currentUserLearningLanguage'?"
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add as \'${wordToConfirm.wordLanguage}\''),
              onPressed: () {
                Navigator.of(context).pop();
                _forceAddWord(wordToConfirm); // Add with originally specified language
              },
            ),
            TextButton(
              child: Text('Correct to \'$_currentUserLearningLanguage\''),
              onPressed: () {
                Navigator.of(context).pop();
                final correctedWord = Word(
                  wordId: wordToConfirm.wordId,
                  wordText: wordToConfirm.wordText,
                  wordLanguage: _currentUserLearningLanguage, // Corrected language
                  explanationLanguage: wordToConfirm.explanationLanguage,
                  markdownExplanation: wordToConfirm.markdownExplanation,
                  pronunciation: wordToConfirm.pronunciation,
                  definitions: wordToConfirm.definitions,
                  examples: wordToConfirm.examples,
                  createdAt: wordToConfirm.createdAt,
                  providerModelName: wordToConfirm.providerModelName,
                );
                _wordLanguageController.text = _currentUserLearningLanguage; // Update field
                _forceAddWord(correctedWord);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _forceAddWord(Word word) async {
      setState(() { _isSaving = true; });
      try {
        // This call assumes the backend can handle the re-submission,
        // or the service/controller logic for addWord needs to be adjusted
        // to bypass the initial language check if a "force" flag is present,
        // or the backend logic is robust enough to handle it based on provided WordLanguage.
        // For now, we assume the backend will re-evaluate based on the Word object sent.
        final addedWord = await _vocabularyService.addWord(word);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Word "${addedWord.wordText}" added successfully!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Still failed to add word: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isSaving = false; });
        }
      }
  }


  @override
  void dispose() {
    _wordTextController.dispose();
    _wordLanguageController.dispose();
    _explanationLanguageController.dispose();
    _markdownExplanationController.dispose();
    _pronunciationController.dispose();
    _definitionsController.dispose();
    _examplesController.dispose();
    _providerModelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Word'),
        actions: [
          IconButton(
            icon: _isSaving ? const SizedBox(width:24, height:24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0,)) : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveWord,
            tooltip: 'Save Word',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _wordTextController,
                decoration: const InputDecoration(labelText: 'Word/Phrase*'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the word or phrase';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _wordLanguageController,
                decoration: const InputDecoration(
                  labelText: 'Word Language*',
                  hintText: 'e.g., en, es, zh-CN',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the word language';
                  }
                  // Basic validation for language code format (e.g., 2 letters, or 2 letters + hyphen + 2 letters)
                  // This is a very basic check.
                  if (!RegExp(r'^[a-z]{2}(-[A-Z]{2})?$').hasMatch(value.trim())) {
                     // return 'Invalid language code format (e.g., en, zh-CN)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _explanationLanguageController,
                decoration: const InputDecoration(
                  labelText: 'Explanation Language (Your Native Language)*',
                  hintText: 'e.g., en, es, zh-CN',
                ),
                 validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the explanation language';
                  }
                   if (!RegExp(r'^[a-z]{2}(-[A-Z]{2})?$').hasMatch(value.trim())) {
                     // return 'Invalid language code format (e.g., en, zh-CN)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _markdownExplanationController,
                decoration: const InputDecoration(labelText: 'Markdown Explanation*'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the markdown explanation';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text('Optional Details', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: _pronunciationController,
                decoration: const InputDecoration(labelText: 'Pronunciation (IPA, etc.)'),
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _definitionsController,
                decoration: const InputDecoration(labelText: 'Definitions (JSON or Text)'),
                 maxLines: 3,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _examplesController,
                decoration: const InputDecoration(labelText: 'Example Sentences (JSON or Text)'),
                 maxLines: 3,
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _providerModelNameController,
                decoration: const InputDecoration(labelText: 'LLM Provider Model Name'),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveWord,
                  child: _isSaving ? const SizedBox(width:20, height:20, child: CircularProgressIndicator(strokeWidth: 2.0,)) : const Text('Save Word'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}