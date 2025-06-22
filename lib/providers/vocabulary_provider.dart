import 'package:flutter/foundation.dart';
import 'package:new_words/app_config.dart';
import 'package:new_words/entities/add_word_request.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/exceptions/api_exception.dart';
import 'package:new_words/services/vocabulary_service.dart';
import 'package:new_words/user_session.dart'; // To get language preferences
import 'package:new_words/utils/util.dart'; // For formatUnixTimestampToLocalDate

class VocabularyProvider with ChangeNotifier {
  final VocabularyService _vocabularyService;

  VocabularyProvider(this._vocabularyService);

  List<WordExplanation> _words = [];
  List<WordExplanation> get words => _words;
  
  // New property for grouped words by date string
  Map<String, List<WordExplanation>> groupedWords = {};

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
      final pageData = await _vocabularyService.listWords(_currentPage, _pageSize);
      if (loadMore) {
        _words.addAll(pageData.dataList);
      } else {
        _words = pageData.dataList;
      }
      _totalWords = pageData.totalCount;
      if (pageData.dataList.isNotEmpty) {
           _currentPage++; // Increment current page if data was fetched
      }
      
      // Group words by date after updating the list
      _groupWordsByDate();
    } on ApiException catch (e) {
      _listError = e.toString();
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
      // Format the createdAt timestamp to local date string using Util with 'yyyy-MM-dd' format
      final dateKey = Util.formatUnixTimestampToLocalDate(word.createdAt, 'yyyy-MM-dd');
      
      if (!groupedWords.containsKey(dateKey)) {
        groupedWords[dateKey] = [];
      }
      groupedWords[dateKey]!.add(word);
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
      learningLanguage: learningLanguage,
      explanationLanguage: nativeLanguage,
    );

    try {
      final newWord = await _vocabularyService.addWord(request);
      // Case-insensitive duplicate check
      final newWordLower = newWord.wordText.toLowerCase();
      if (!_words.any((w) => w.wordText.toLowerCase() == newWordLower)) {
        _words.insert(0, newWord);
        _totalWords++; // Increment total words
        // Update grouped words after adding new word
        _groupWordsByDate();
      }
      _isLoadingAdd = false;
      notifyListeners();
      return newWord;
    } on ApiException catch (e) {
      _addError = e.toString();
    } catch (e) {
      _addError = e.toString();
    } finally {
      _isLoadingAdd = false;
      notifyListeners();
    }
    return null;
  }

  Future<bool> deleteWord(int wordId) async {
    try {
      await _vocabularyService.deleteWord(wordId);
      // Remove the word from the list
      _words.removeWhere((word) => word.id == wordId);
      _totalWords--; // Decrement total words
      // Update grouped words after deletion
      _groupWordsByDate();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}