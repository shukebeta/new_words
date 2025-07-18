import 'package:new_words/apis/vocabulary_api.dart';
import 'package:new_words/entities/api_result.dart';
import 'package:new_words/entities/word_explanation.dart';
import 'package:new_words/exceptions/api_exception.dart';
import 'package:new_words/utils/device_timezone.dart';

class MemoriesService {
  final VocabularyApi _vocabularyApi;

  MemoriesService(this._vocabularyApi);

  /// Get words for spaced repetition review
  Future<List<WordExplanation>> getSpacedRepetitionWords() async {
    final timezone = DeviceTimezone.getTimezoneForApi();

    final response = await _vocabularyApi.getMemories(timezone);
    final result = ApiResult<List<WordExplanation>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          (json as List)
              .map(
                (item) =>
                    WordExplanation.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(result.errorMessage ?? 'Failed to load memory words');
    }
  }

  /// Get words learned on a specific date
  Future<List<WordExplanation>> getWordsFromDate(DateTime date) async {
    final timezone = DeviceTimezone.getTimezoneForApi();
    final dateString = DeviceTimezone.formatDateForApi(date);

    final response = await _vocabularyApi.getMemoriesOnDate(
      timezone,
      dateString,
    );
    final result = ApiResult<List<WordExplanation>>.fromJson(
      response.data as Map<String, dynamic>,
      (json) =>
          (json as List)
              .map(
                (item) =>
                    WordExplanation.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );

    if (result.isSuccess && result.data != null) {
      return result.data!;
    } else {
      throw ApiException(
        result.errorMessage ?? 'Failed to load words for date',
      );
    }
  }
}
