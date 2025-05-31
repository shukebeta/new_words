import 'package:flutter/foundation.dart';
import 'package:new_words/apis/vocabulary_api.dart';
import 'package:new_words/app_config.dart';
import 'package:new_words/entities/add_word_request.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/user_session.dart'; // To get language preferences

class VocabularyProvider with ChangeNotifier {
  final VocabularyApi _vocabularyApi;

  VocabularyProvider(this._vocabularyApi);

  List<WordExplanation> _words = [];
  List<WordExplanation> get words => _words;
  
  // New property for grouped words by date
  Map<DateTime, List<WordExplanation>> groupedWords = {};

  bool _isLoadingList = false;
  bool get isLoadingList => _isLoadingList;

  bool _isLoadingAdd = false;
  bool get isLoadingAdd => _isLoadingAdd;

  String? _listError;
  String? get listError => _listError;

  String? _addError;
  String? get addError => _addError;

  int _currentPage = 1;
  int _totalWords = 0;
  final int _pageSize = AppConfig.pageSize; // Get page size from AppConfig

  bool get canLoadMore => _words.length < _totalWords;

  Future<void> fetchWords({bool loadMore = false}) async {
    if (_isLoadingList) return;
    if (loadMore && !canLoadMore) return;

    _isLoadingList = true;
    _listError = null;
    if (!loadMore) {
      _currentPage = 1;
      _words = [];
      groupedWords = {}; // Reset grouped words when refreshing
    }
    notifyListeners();

    try {
      final result = await _vocabularyApi.listWords(_currentPage, _pageSize);
      if (result.isSuccess && result.data != null) {
        if (loadMore) {
          _words.addAll(result.data!.dataList);
        } else {
          _words = result.data!.dataList;
        }
        _totalWords = result.data!.totalCount;
        if (result.data!.dataList.isNotEmpty) {
             _currentPage++; // Increment current page if data was fetched
        }
        
        // Group words by date after updating the list
        _groupWordsByDate();
      } else {
        _listError = result.errorMessage ?? "Failed to load words.";
      }
    } catch (e) {
      _listError = e.toString();
    } finally {
      _isLoadingList = false;
      notifyListeners();
    }
  }

  // New method to group words by date
  void _groupWordsByDate() {
    groupedWords = {};
    for (final word in _words) {
      // Convert createdAt timestamp to DateTime (assuming seconds since epoch)
      final dateTime = DateTime.fromMillisecondsSinceEpoch(word.createdAt * 1000);
      // Use the date part only (without time) for grouping
      final date = DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day
      );
      
      if (!groupedWords.containsKey(date)) {
        groupedWords[date] = [];
      }
      groupedWords[date]!.add(word);
    }
  }

  Future<void> refreshWords() async {
    _currentPage = 1;
    _words = [];
    groupedWords = {}; // Clear grouped words when refreshing
    await fetchWords();
  }

  Future<WordExplanation?> addNewWord(String wordText) async {
    if (_isLoadingAdd) return null;

    _isLoadingAdd = true;
    _addError = null;
    notifyListeners();

    final session = UserSession();
    final learningLanguage = session.currentLearningLanguage;
    final nativeLanguage = session.nativeLanguage;

    if (learningLanguage == null || learningLanguage.isEmpty) {
      _addError = "Learning language not set.";
      _isLoadingAdd = false;
      notifyListeners();
      return null;
    }
    if (nativeLanguage == null || nativeLanguage.isEmpty) {
      _addError = "Native language not set.";
      _isLoadingAdd = false;
      notifyListeners();
      return null;
    }

    final request = AddWordRequest(
      wordText: wordText,
      wordLanguage: learningLanguage,
      explanationLanguage: nativeLanguage,
    );

    try {
      final result = await _vocabularyApi.addWord(request);
      if (result.isSuccess && result.data != null) {
        // Case-insensitive duplicate check
        final newWordLower = result.data!.wordText.toLowerCase();
        if (!_words.any((w) => w.wordText.toLowerCase() == newWordLower)) {
          _words.insert(0, result.data!);
          _totalWords++; // Increment total words
          // Update grouped words after adding new word
          _groupWordsByDate();
        }
        _isLoadingAdd = false;
        notifyListeners();
        return result.data!;
      } else {
        _addError = result.errorMessage ?? "Failed to add word.";
      }
    } catch (e) {
      _addError = e.toString();
    } finally {
      _isLoadingAdd = false;
      notifyListeners();
    }
    return null;
  }
}