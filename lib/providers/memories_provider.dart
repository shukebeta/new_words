import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/services/memories_service_v2.dart';
import 'package:new_words/utils/device_timezone.dart';
import 'package:new_words/utils/util.dart';
import 'package:new_words/providers/provider_base.dart';

class MemoriesProvider extends AuthAwareProvider {
  final MemoriesServiceV2 _memoriesService;

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

    final result = await executeWithErrorHandling<List<WordExplanation>>(
      operation: () => _memoriesService.getSpacedRepetitionWords(),
      setLoading: (loading) => _isLoadingMemories = loading,
      setError: (error) => _memoriesError = error,
      operationName: 'load memories',
    );
    
    if (result != null) {
      _memoryWords = result;
    }
  }

  /// Load words for a specific date
  Future<void> loadWordsForDate(DateTime date) async {
    if (_isLoadingDate) return;

    _selectedDate = date;
    
    final result = await executeWithErrorHandling<List<WordExplanation>>(
      operation: () => _memoriesService.getWordsFromDate(date),
      setLoading: (loading) => _isLoadingDate = loading,
      setError: (error) => _dateError = error,
      operationName: 'load words for date',
    );
    
    if (result != null) {
      _dateWords = result;
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
    // Don't load data here - let the MemoriesScreen load it when mounted
    // This implements lazy loading for better performance
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
