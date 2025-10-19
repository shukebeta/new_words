import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/features/add_word/presentation/add_word_dialog.dart';
import 'package:new_words/providers/vocabulary_provider.dart';
import 'package:new_words/generated/app_localizations.dart';

class WordDetailScreen extends StatefulWidget {
  final WordExplanation wordExplanation;

  const WordDetailScreen({super.key, required this.wordExplanation});

  static const routeName = '/word-detail';

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  late WordExplanation _currentExplanation;

  // New state for multiple explanations
  List<WordExplanation> _allExplanations = [];
  int _selectedIndex = 0;
  bool _allModelsExhausted = false;
  int? _userDefaultExplanationId;

  @override
  void initState() {
    super.initState();
    _currentExplanation = widget.wordExplanation;
    _userDefaultExplanationId = widget.wordExplanation.id;

    // Initialize with current explanation - show immediately without blocking
    _allExplanations = [_currentExplanation];
    _selectedIndex = 0;

    // Load other explanations asynchronously in background
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExplanationsInBackground();
    });
  }

  Future<void> _loadExplanationsInBackground() async {
    // Check if wordCollectionId is valid (0 means old data before migration)
    if (_currentExplanation.wordCollectionId <= 0) {
      return;
    }

    try {
      final provider = Provider.of<VocabularyProvider>(context, listen: false);
      final response = await provider.loadExplanationsForWord(_currentExplanation);

      if (!mounted) return;

      setState(() {
        _allExplanations = response.explanations;
        _userDefaultExplanationId = response.userDefaultExplanationId;

        // Always show user's default explanation when entering detail screen
        _selectedIndex = _allExplanations.indexWhere(
          (e) => e.id == _userDefaultExplanationId,
        );
        if (_selectedIndex == -1) _selectedIndex = 0;

        // Update to show default explanation
        if (_allExplanations.isNotEmpty) {
          _currentExplanation = _allExplanations[_selectedIndex];
        }
      });
    } catch (e) {
      // Graceful degradation: keep showing current explanation
      // No need to update UI - user can already see the content
    }
  }

  void _previousExplanation() {
    setState(() {
      // Circular navigation: go to last if at first
      _selectedIndex = _selectedIndex > 0
          ? _selectedIndex - 1
          : _allExplanations.length - 1;
      _currentExplanation = _allExplanations[_selectedIndex];
    });
  }

  void _nextExplanation() {
    setState(() {
      // Circular navigation: go to first if at last
      _selectedIndex = _selectedIndex < _allExplanations.length - 1
          ? _selectedIndex + 1
          : 0;
      _currentExplanation = _allExplanations[_selectedIndex];
    });
  }

  Future<void> _setAsPreferred() async {
    try {
      final provider = Provider.of<VocabularyProvider>(context, listen: false);
      await provider.switchExplanation(
        _currentExplanation.wordCollectionId,
        _currentExplanation.id,
      );

      if (!mounted) return;

      setState(() {
        _userDefaultExplanationId = _currentExplanation.id;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.defaultExplanationUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.failedToUpdateDefault}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool get _canRefresh {
    // Only disable refresh when backend says all models are exhausted
    return !_allModelsExhausted;
  }

  Future<void> _refreshExplanation() async {
    final provider = Provider.of<VocabularyProvider>(context, listen: false);

    final result = await provider.refreshExplanation(_currentExplanation);

    if (!mounted) return;

    if (result.isSuccess) {
      if (result.wasUpdated && result.updatedExplanation != null) {
        final newExplanation = result.updatedExplanation!;

        // Reset exhausted flag - successful refresh means there was an available model
        setState(() {
          _allModelsExhausted = false;
        });

        // Reload all explanations to include the new one
        await _loadExplanationsInBackground();

        // Switch to the newly generated explanation
        final newIndex = _allExplanations.indexWhere((e) => e.id == newExplanation.id);
        if (newIndex != -1) {
          setState(() {
            _selectedIndex = newIndex;
            _currentExplanation = _allExplanations[newIndex];
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.newExplanationGenerated),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      // Check for models exhausted error
      if (result.message.contains('All available models')) {
        setState(() => _allModelsExhausted = true);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Widget _buildVersionNavigator() {
    if (_allExplanations.length <= 1) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousExplanation,
        ),
        Text(
          '${_selectedIndex + 1}/${_allExplanations.length}',
          style: const TextStyle(fontSize: 14),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextExplanation,
        ),
      ],
    );
  }

  Widget _buildDefaultIndicator() {
    final isDefault = _currentExplanation.id == _userDefaultExplanationId;

    if (isDefault) {
      return Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            AppLocalizations.of(context)!.preferred,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      );
    } else {
      return TextButton.icon(
        onPressed: _setAsPreferred,
        icon: const Icon(Icons.star_border, size: 16),
        label: Text(AppLocalizations.of(context)!.setAsPreferred),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VocabularyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            title: Text(_currentExplanation.wordText),
            actions: [
              _buildVersionNavigator(),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Default indicator
                if (_allExplanations.length > 1) ...[
                  _buildDefaultIndicator(),
                  const SizedBox(height: 8),
                ],
                const Divider(),
                MarkdownBody(
                  data: _currentExplanation.markdownExplanation,
                  selectable: true,
                ),
                const Divider(),
                Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.generatedByPrefix} ${_currentExplanation.providerModelName ?? AppLocalizations.of(context)!.unknownModel}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (provider.isRefreshing)
                      Text(
                        AppLocalizations.of(context)!.refreshingText,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      )
                    else
                      GestureDetector(
                        onTap: _canRefresh ? _refreshExplanation : null,
                        child: Text(
                          AppLocalizations.of(context)!.refreshButton,
                          style: TextStyle(
                            fontSize: 12,
                            color: _canRefresh
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async => AddWordDialog.show(context, replacePage: true),
            tooltip: 'Add New Word',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
