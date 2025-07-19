import 'package:new_words/apis/vocabulary_api_v2.dart';
import 'package:new_words/common/foundation/foundation.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/utils/app_logger.dart';
import 'package:new_words/utils/app_logger_interface.dart';
import 'package:new_words/utils/device_timezone.dart';

/// Modern memories service implementation using BaseService foundation
/// 
/// This class replaces the old MemoriesService with standardized error handling,
/// logging patterns, and centralized exception management.
class MemoriesServiceV2 extends BaseService {
  final VocabularyApiV2 _vocabularyApi;
  final AppLoggerInterface _logger;

  MemoriesServiceV2({
    required VocabularyApiV2 vocabularyApi,
    AppLoggerInterface? logger,
  })  : _vocabularyApi = vocabularyApi,
        _logger = logger ?? AppLogger.instance;

  /// Get words for spaced repetition review
  Future<List<WordExplanation>> getSpacedRepetitionWords() async {
    logOperation('getSpacedRepetitionWords');

    try {
      final timezone = DeviceTimezone.getTimezoneForApi();
      final response = await _vocabularyApi.getMemories(timezone);
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }

  /// Get words learned on a specific date
  Future<List<WordExplanation>> getWordsFromDate(DateTime date) async {
    logOperation('getWordsFromDate', parameters: {
      'date': date.toIso8601String(),
    });

    try {
      final timezone = DeviceTimezone.getTimezoneForApi();
      final dateString = DeviceTimezone.formatDateForApi(date);
      
      final response = await _vocabularyApi.getMemoriesOnDate(
        timezone,
        dateString,
      );
      return processResponse(response);
    } catch (e) {
      throw ServiceExceptionFactory.fromException(e);
    }
  }
}