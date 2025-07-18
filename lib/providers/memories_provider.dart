import 'package:flutter/foundation.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/exceptions/api_exception.dart';
import 'package:new_words/services/memories_service.dart';
import 'package:new_words/utils/device_timezone.dart';
import 'package:new_words/utils/util.dart';
import 'package:new_words/providers/provider_base.dart';

class MemoriesProvider extends AuthAwareProvider {
  final MemoriesService _memoriesService;

  MemoriesProvider(this._memoriesService);

  // Spaced repetition words
  List<WordExplanation> _memoryWords = [];
  List<WordExplanation> get memoryWords => _memoryWords;

  // Words for specific date
  List<WordExplanation> _dateWords = [];
  List<WordExplanation> get dateWords => _dateWords;

  // Loading states
  bool _isLoadingMemories = false;
  bool get isLoadingMemories => _isLoadingMemories;

  bool _isLoadingDate = false;
  bool get isLoadingDate => _isLoadingDate;

  // Error states
  String? _memoriesError;
  String? get memoriesError => _memoriesError;

  String? _dateError;
  String? get dateError => _dateError;

  // Selected date for date-specific queries
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  /// Load spaced repetition words
  Future<void> loadSpacedRepetitionWords() async {
    if (_isLoadingMemories) return;

    _isLoadingMemories = true;
    _memoriesError = null;
    notifyListeners();

    try {
      _memoryWords = await _memoriesService.getSpacedRepetitionWords();
    } on ApiException catch (e) {
      _memoriesError = e.toString();
    } catch (e) {
      _memoriesError = 'Failed to load memories: ${e.toString()}';
    } finally {
      _isLoadingMemories = false;
      notifyListeners();
    }
  }

  /// Load words for a specific date
  Future<void> loadWordsForDate(DateTime date) async {
    if (_isLoadingDate) return;

    _isLoadingDate = true;
    _dateError = null;
    _selectedDate = date;
    notifyListeners();

    try {
      _dateWords = await _memoriesService.getWordsFromDate(date);
    } on ApiException catch (e) {
      _dateError = e.toString();
    } catch (e) {
      _dateError = 'Failed to load words for date: ${e.toString()}';
    } finally {
      _isLoadingDate = false;
      notifyListeners();
    }
  }

  /// Extract date from a word's createdAt timestamp and load words for that date
  Future<void> loadWordsForWordDate(WordExplanation word) async {
    final learnedDate = word.learnedDate;
    await loadWordsForDate(learnedDate);
  }

  /// Refresh memories
  Future<void> refreshMemories() async {
    _memoryWords = [];
    await loadSpacedRepetitionWords();
  }

  /// Clear date-specific data
  void clearDateData() {
    _dateWords = [];
    _selectedDate = null;
    _dateError = null;
    notifyListeners();
  }

  /// Clear all data
  @override
  void clearAllData() {
    _memoryWords = [];
    _dateWords = [];
    _selectedDate = null;
    _memoriesError = null;
    _dateError = null;
    _isLoadingMemories = false;
    _isLoadingDate = false;
    // Force immediate UI update
    notifyListeners();
  }

  /// Load initial data when user logs in
  @override
  Future<void> onLogin() async {
    // Load spaced repetition words
    await loadSpacedRepetitionWords();
  }

  /// Get spaced repetition text for a word
  String getSpacedRepetitionText(WordExplanation word) {
    return DeviceTimezone.getSpacedRepetitionText(word.learnedDate);
  }

  /// Get formatted date string for selected date
  String get selectedDateString {
    if (_selectedDate == null) return '';
    return Util.formatUnixTimestampToLocalDate(
      _selectedDate!.millisecondsSinceEpoch ~/ 1000,
      'EEEE, MMM d, yyyy',
    );
  }

  /// Check if there are any memory words available
  bool get hasMemoryWords => _memoryWords.isNotEmpty;

  /// Check if there are any words for the selected date
  bool get hasDateWords => _dateWords.isNotEmpty;

  /// Get total count of memory words
  int get memoryWordsCount => _memoryWords.length;

  /// Get total count of date words
  int get dateWordsCount => _dateWords.length;
}
